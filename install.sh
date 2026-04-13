#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── Detect package manager ────────────────────────────────────────────
if command -v apt &>/dev/null; then
    PM="apt"
    INSTALL="sudo apt install -y"
elif command -v pacman &>/dev/null; then
    PM="pacman"
    INSTALL="sudo pacman -S --noconfirm"
elif command -v dnf &>/dev/null; then
    PM="dnf"
    INSTALL="sudo dnf install -y"
elif command -v brew &>/dev/null; then
    PM="brew"
    INSTALL="brew install"
else
    echo "Unsupported package manager" && exit 1
fi

echo "==> Detected package manager: $PM"

# ── System packages ───────────────────────────────────────────────────
echo "==> Installing system packages..."
$INSTALL fish stow git curl unzip

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
                DEBIAN_CODENAME=$(lsb_release -sc)
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

# ── Rust & cargo tools ───────────────────────────────────────────────
echo "==> Installing Rust..."
if ! command -v cargo &>/dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi

echo "==> Installing cargo packages..."
cargo install ast-grep bat eza fd-find ripgrep starship zoxide dipc

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
for pkg in fish starship ghostty btop; do
    if [ -d "$DOTFILES_DIR/$pkg" ]; then
        # --restow: safely re-creates symlinks, works on both fresh and existing installs
        stow --restow "$pkg"
    else
        echo "  Skipping $pkg (not found in dotfiles)"
    fi
done

# ── Set fish as default shell ─────────────────────────────────────────
echo "==> Setting fish as default shell..."
FISH_PATH=$(which fish)
grep -q "$FISH_PATH" /etc/shells || echo "$FISH_PATH" | sudo tee -a /etc/shells
chsh -s "$FISH_PATH"

echo ""
echo "✓ Done! A few more things:"
echo "  1. Log out and back in for the shell change to take effect"
echo "  2. Run 'nvim' once to let NvChad finish installing plugins"
echo "  3. If Ghostty was installed via snap and fails to launch, reboot first"