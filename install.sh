#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── Detect package manager ────────────────────────────────────────────
if command -v apt &>/dev/null; then
    PM="apt"
    INSTALL="sudo apt install -y"
    BUILD_PKGS="build-essential pkg-config fontconfig"
elif command -v pacman &>/dev/null; then
    PM="pacman"
    INSTALL="sudo pacman -S --noconfirm"
    BUILD_PKGS="base-devel fontconfig"
elif command -v dnf &>/dev/null; then
    PM="dnf"
    INSTALL="sudo dnf install -y"
    BUILD_PKGS="gcc make pkgconf-pkg-config fontconfig"
elif command -v brew &>/dev/null; then
    PM="brew"
    INSTALL="brew install"
    BUILD_PKGS=""
else
    echo "Unsupported package manager" && exit 1
fi

echo "==> Detected package manager: $PM"

# ── System packages ───────────────────────────────────────────────────
# build tools + fontconfig are needed later for `cargo install` (linking) and `fc-cache`
echo "==> Installing system packages..."
$INSTALL fish stow git curl unzip $BUILD_PKGS

# ── fzf ──────────────────────────────────────────────────────────────
echo "==> Installing fzf..."
if [ ! -d "$HOME/.fzf" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all --no-bash --no-zsh
else
    echo "fzf already installed, skipping."
fi

# ── fastfetch ─────────────────────────────────────────────────────────
echo "==> Installing fastfetch..."
if ! command -v fastfetch &>/dev/null; then
    if [ "$PM" = "apt" ]; then
        if apt-cache show fastfetch &>/dev/null 2>&1; then
            sudo apt install -y fastfetch
        else
            sudo apt install -y software-properties-common
            sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch
            sudo apt update
            sudo apt install -y fastfetch
        fi
    elif [ "$PM" = "pacman" ]; then
        sudo pacman -S --noconfirm fastfetch
    elif [ "$PM" = "dnf" ]; then
        sudo dnf install -y fastfetch
    elif [ "$PM" = "brew" ]; then
        brew install fastfetch
    fi
else
    echo "fastfetch already installed, skipping."
fi

# ── Ghostty ───────────────────────────────────────────────────────────
echo "==> Installing Ghostty..."
if ! command -v ghostty &>/dev/null; then
    if [ "$PM" = "pacman" ]; then
        sudo pacman -S --noconfirm ghostty

    elif [ "$PM" = "dnf" ]; then
        sudo dnf install -y ghostty

    elif [ "$PM" = "brew" ]; then
        brew install --cask ghostty

    elif [ "$PM" = "apt" ]; then
        DISTRO_ID=$(grep "^ID=" /etc/os-release | cut -d= -f2 | tr -d '"')

        if [ "$DISTRO_ID" = "ubuntu" ]; then
            # mkasberg/ghostty-ubuntu — Ubuntu official installer
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"

        else
            # dariogriffo/ghostty-debian — covers Debian, Kali, etc.
            # Kali reports "kali-rolling" which isn't in the repo — map it to "sid"
            if [ "$DISTRO_ID" = "kali" ]; then
                DEBIAN_CODENAME="sid"
            else
                # Read straight from /etc/os-release instead of lsb_release,
                # which isn't installed by default on minimal Debian/Ubuntu.
                DEBIAN_CODENAME=$(grep "^VERSION_CODENAME=" /etc/os-release | cut -d= -f2 | tr -d '"')
            fi

            sudo curl -fsSL https://debian.griffo.io/EA0F721D231FDD3A0A17B9AC7808B4DD62C41256.asc \
                | sudo gpg --dearmor -o /usr/share/keyrings/debian.griffo.io.gpg
            echo "deb [signed-by=/usr/share/keyrings/debian.griffo.io.gpg] \
                https://debian.griffo.io/apt $DEBIAN_CODENAME main" \
                | sudo tee /etc/apt/sources.list.d/debian.griffo.io.list
            sudo apt update
            sudo apt install -y ghostty
        fi
    fi
else
    echo "Ghostty already installed, skipping."
fi

# ── Neovim (latest stable, cross-distro) ─────────────────────────────
echo "==> Installing Neovim..."
if ! command -v nvim &>/dev/null; then
    NVIM_INSTALL_DIR="/opt/nvim-linux-x86_64"
    NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"

    sudo rm -rf "$NVIM_INSTALL_DIR"
    curl -Lo /tmp/nvim.tar.gz "$NVIM_URL"
    sudo tar -C /opt -xzf /tmp/nvim.tar.gz
    rm /tmp/nvim.tar.gz

    # Wrapper script so VIMRUNTIME is always set regardless of shell or invocation context
    sudo tee /usr/local/bin/nvim > /dev/null << EOF
#!/usr/bin/env bash
export VIMRUNTIME=${NVIM_INSTALL_DIR}/share/nvim/runtime
exec ${NVIM_INSTALL_DIR}/bin/nvim "\$@"
EOF
    sudo chmod +x /usr/local/bin/nvim
else
    echo "Neovim already installed, skipping."
fi

# ── NvChad ────────────────────────────────────────────────────────────
echo "==> Setting up NvChad..."
if [ ! -d "$HOME/.config/nvim" ]; then
    git clone https://github.com/NvChad/starter ~/.config/nvim
    rm -rf ~/.config/nvim/.git
    echo "NvChad cloned. Neovim will finish setup on first launch."
else
    echo "~/.config/nvim already exists, skipping NvChad setup."
fi

# ── Native package manager tools ────────────────────────────────────
# These are packaged (and conflict-free) on every distro we support, so
# installing them here is both much faster than a cargo build and avoids
# eza's currently-broken crates.io dependency resolution (see below).
# bat stays on cargo: on some Debian/Ubuntu releases its package installs
# the binary as `batcat` instead of `bat`, which would break the
# `alias cat='bat ...'` in config.fish.
echo "==> Installing native CLI tools (eza, ripgrep, zoxide, starship, git-delta, btop)..."
for pkg in eza ripgrep zoxide starship git-delta btop; do
    # command names differ from package names for a couple of these
    case "$pkg" in
        ripgrep) bin="rg" ;;
        git-delta) bin="delta" ;;
        *) bin="$pkg" ;;
    esac

    if command -v "$bin" &>/dev/null; then
        echo "  $bin already installed, skipping."
        continue
    fi

    case "$PM" in
        apt) sudo apt install -y "$pkg" ;;
        pacman) sudo pacman -S --noconfirm "$pkg" ;;
        dnf) sudo dnf install -y "$pkg" ;;
        brew) brew install "$pkg" ;;
    esac
done

# ── Rust & cargo tools ───────────────────────────────────────────────
echo "==> Installing Rust..."
if ! command -v cargo &>/dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi

echo "==> Installing cargo packages..."
# du-dust -> dust, procs -> procs: referenced in config.fish
cargo install ast-grep bat fd-find dipc du-dust procs

# ── uv (Python env manager) ───────────────────────────────────────────
echo "==> Installing uv..."
if ! command -v uv &>/dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
else
    echo "uv already installed, skipping."
fi

# ── JetBrainsMono Nerd Font ───────────────────────────────────────────
echo "==> Installing JetBrainsMono Nerd Font..."
FONT_DIR="$HOME/.local/share/fonts"
if [ ! -d "$FONT_DIR/JetBrainsMono" ]; then
    mkdir -p "$FONT_DIR"
    curl -Lo /tmp/JetBrainsMono.zip \
        "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
    unzip -o /tmp/JetBrainsMono.zip -d "$FONT_DIR/JetBrainsMono"
    fc-cache -fv
    rm /tmp/JetBrainsMono.zip
else
    echo "JetBrainsMono Nerd Font already installed, skipping."
fi

# ── Stow dotfiles ─────────────────────────────────────────────────────
echo "==> Stowing dotfiles..."
cd "$DOTFILES_DIR"

BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d%H%M%S)"
BACKED_UP=false

for pkg in fish starship ghostty btop nvim; do
    if [ -d "$DOTFILES_DIR/$pkg" ]; then
        # A fresh OS/app install can leave real (non-symlink) config files in place,
        # e.g. ~/.config/ghostty/config generated on first launch. stow refuses to
        # touch those, so move them aside first instead of failing the whole script.
        while IFS= read -r -d '' file; do
            rel="${file#"$DOTFILES_DIR"/"$pkg"/}"
            target="$HOME/$rel"
            if [ -e "$target" ] && [ ! -L "$target" ]; then
                mkdir -p "$(dirname "$BACKUP_DIR/$rel")"
                mv "$target" "$BACKUP_DIR/$rel"
                BACKED_UP=true
            fi
        done < <(find "$DOTFILES_DIR/$pkg" -type f -print0)

        # --restow: safely re-creates symlinks, works on both fresh and existing installs
        # -t/--target is explicit: stow's default target is the *parent* of the
        # directory it's run from, which is only $HOME by coincidence if this repo
        # happens to be cloned straight into $HOME. Pin it so this works from any path.
        stow --restow --target="$HOME" "$pkg"
    else
        echo "  Skipping $pkg (not found in dotfiles)"
    fi
done

if [ "$BACKED_UP" = true ]; then
    echo "  Pre-existing configs backed up to $BACKUP_DIR"
fi

# ── Set fish as default shell ─────────────────────────────────────────
echo "==> Setting fish as default shell..."
FISH_PATH=$(which fish)
grep -q "$FISH_PATH" /etc/shells || echo "$FISH_PATH" | sudo tee -a /etc/shells
chsh -s "$FISH_PATH"

echo ""
echo "✓ Done! A few more things:"
echo "  1. Log out and back in for the shell change to take effect"
echo "  2. Run 'nvim' once to let NvChad finish installing plugins"
echo "     (this also compiles the Catppuccin Frappe theme override in"
echo "     chadrc.lua for the first time -- it only auto-compiles on that"
echo "     first plugin install, so if you edit chadrc.lua's colors again"
echo "     later on an already-installed nvim, force a recompile with:"
echo "     nvim --headless -c \"lua require('base46').load_all_highlights()\" -c qa"
echo "  3. If Ghostty was installed via snap and fails to launch, reboot first"