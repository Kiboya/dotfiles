# ~/.config/fish/config.fish
# Bastien's Fish configuration
# --------------------------------------------

# ====== Abbreviations ======
abbr -a c clear
abbr -a l ls
abbr -a du dust
abbr -a ps procs
abbr -a neofetch fastfetch

# ====== Aliases ======
alias cat='bat --paging=never --style=plain --color=always'
alias less='bat --paging=always --style=plain --color=always'
alias ls='eza -g --icons --header --group-directories-first --color=always'
alias la='eza -ag --icons --header --group-directories-first --color=always'
alias ll='eza -lg --icons --header --group-directories-first --color=always'
alias lr='eza -lTg -L 2 --icons --header --group-directories-first --color=always'
alias lR='eza -lTg --icons --header --group-directories-first --color=always'

# ====== Environment variables ======
set -gx EDITOR nvim
set -gx VIM nvim
set -gx fish_greeting
set -gx DELTA_PAGER "less -r --mouse"

# ====== PATH additions ======
fish_add_path ~/.local/bin
fish_add_path ~/.cargo/bin
fish_add_path ~/go/bin

# ====== Initialize tools ======
zoxide init --cmd cd fish | source
starship init fish | source
fzf --fish | source

# ====== Command-not-found handler ======
function __fish_command_not_found_handler --on-event fish_command_not_found
    echo "Command not found: $argv[1]"
end
