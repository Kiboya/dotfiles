# Catppuccin Frappe color theme for fish, matching the btop theme already
# in this repo (btop/.config/btop/themes/catppuccin_frappe.theme).
#
# This uses `set -g` rather than `fish_config theme choose` + universal
# variables on purpose: universal variables live in fish_variables, which
# this repo's .gitignore excludes (correctly, it's mostly machine state).
# A `set -g` in conf.d is re-applied on every new shell, so the theme is
# actually reproducible across fresh installs instead of living only in
# untracked local state.

set -g fish_color_normal c6d0f5
set -g fish_color_command 8caaee
set -g fish_color_keyword ca9ee6
set -g fish_color_quote a6d189
set -g fish_color_redirection f4b8e4
set -g fish_color_end babbf1
set -g fish_color_error e78284 --bold
set -g fish_color_param c6d0f5
set -g fish_color_comment 737994
set -g fish_color_selection --background=414559
set -g fish_color_search_match --background=414559
set -g fish_color_operator 85c1dc
set -g fish_color_escape f4b8e4
set -g fish_color_autosuggestion 737994
set -g fish_color_cwd a6d189
set -g fish_color_cwd_root e78284
set -g fish_color_valid_path --underline
set -g fish_color_option ef9f76
set -g fish_color_history_current --bold

set -g fish_pager_color_prefix 8caaee
set -g fish_pager_color_completion c6d0f5
set -g fish_pager_color_description 737994 -i
set -g fish_pager_color_progress 737994 --background=414559
set -g fish_pager_color_selected_background --background=414559
