# ~/.config/fish/config.fish
# Bastien's Fish configuration

# ======= Abbreviations =======
abbr -a c clear
abbr -a l ls
abbr -a du dust
abbr -a ps procs
abbr -a neofetch fastfetch

# ======= Aliases =======
alias cat='bat --paging=never --style=plain --color=always'
alias less='bat --paging=always --style=plain --color=always'

if test "$TERM_PROGRAM" = vscode
    # VS Code terminal - disable icons
    alias ls='eza -g --header --group-directories-first --color=always'
    alias la='eza -ag --header --group-directories-first --color=always'
    alias ll='eza -lg --header --group-directories-first --color=always'
    alias lr='eza -lTg -L 2 --header --group-directories-first --color=always'
    alias lR='eza -lTg --header --group-directories-first --color=always'
else
    # Normal terminal - enable icons
    alias ls='eza -g --icons --header --group-directories-first --color=always'
    alias la='eza -ag --icons --header --group-directories-first --color=always'
    alias ll='eza -lg --icons --header --group-directories-first --color=always'
    alias lr='eza -lTg -L 2 --icons --header --group-directories-first --color=always'
    alias lR='eza -lTg --icons --header --group-directories-first --color=always'
end

# ======= Environment variables =======
set -gx EDITOR nvim
set -gx VIM nvim
set -gx fish_greeting
set -gx DELTA_PAGER "less -r --mouse"

# ======= PATH additions =======
fish_add_path ~/local/bin
fish_add_path ~/.cargo/bin
fish_add_path ~/.go/bin

# ======= Initialize tools =======
zoxide init --cmd cd fish | source
starship init fish | source
fzf --fish | source

# ======= Starship transient prompt =======
function starship_transient_prompt_func
    # lx is starship module character
    # You can change this in your starship.toml config
    if test "$TERM_PROGRAM" = vscode
        # VS Code: use a simple character, '❯'
        echo -n '❯ '
    else
        # Normal terminal: use the starship character module
        starship module character
    end

    # enable_transience
    # Use starship's transience feature
    # This keeps the full prompt visible, but hides the prompt line after command execution
    # This is a placeholder/conceptual name; you would use the starship command to enable transience
    starship enable transience
end

# ======= Command-not-found handler =======
function __fish_command_not_found_handler --on-event fish_command_not_found
    echo "Command not found: $argv[1]"
end
