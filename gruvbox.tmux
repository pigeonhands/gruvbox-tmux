#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_PATH="$CURRENT_DIR/src"

source "$SCRIPTS_PATH/themes.sh" || {
	echo "Error: Failed to source themes.sh" >&2
	exit 1
}

tmux set -g status-left-length 80
tmux set -g status-right-length 150

tmux set -g mode-style "fg=${THEME[background]},bg=${THEME[foreground]},reverse"

tmux set -g message-style "bg=${THEME[bblue]},fg=${THEME[background]},bold"
tmux set -g message-command-style "fg=${THEME[white]},bg=${THEME[black]},bold"

tmux set -g pane-border-style "fg=${THEME[bblack]}"
tmux set -g pane-active-border-style "fg=${THEME[white]},bold"
tmux set -g pane-border-status off

tmux set -g status-style "fg=${THEME[foreground]},bg=${THEME[background]}"

window_id_style="$(tmux show-option -gv @gruvbox-tmux_window_id_style 2>/dev/null || echo "dsquare")"
pane_id_style="$(tmux show-option -gv @gruvbox-tmux_pane_id_style 2>/dev/null || echo "super")"
zoom_id_style="$(tmux show-option -gv @gruvbox-tmux_zoom_id_style 2>/dev/null || echo "rsquare")"
terminal_icon="$(tmux show-option -gv @gruvbox-tmux_terminal_icon 2>/dev/null || echo '')"
active_terminal_icon="$(tmux show-option -gv @gruvbox-tmux_active_terminal_icon 2>/dev/null || echo '')"

git_status="#($SCRIPTS_PATH/git-status.sh #{pane_current_path})"
wb_git_status="#($SCRIPTS_PATH/wb-git-status.sh #{pane_current_path} &)"
window_number="#($SCRIPTS_PATH/custom-number.sh #I $window_id_style)"
custom_pane="#($SCRIPTS_PATH/custom-number.sh #P $pane_id_style)"
zoom_number="#($SCRIPTS_PATH/custom-number.sh #P $zoom_id_style)"
date_and_time="$($SCRIPTS_PATH/datetime-widget.sh)"
battery_status="#($SCRIPTS_PATH/battery-widget.sh)"
ssh_connection_status="#($SCRIPTS_PATH/ssh-connection.sh #{pane_tty})"

tmux set -g status-left "\
#[fg=${THEME[foreground]},bg=${THEME[blue]},bold] \
#{?client_prefix,󰠠 ,󰤂 }\
#[bold,nodim]#S "

tmux set -g window-status-current-format "\
$RESET#[fg=${THEME[bgreen]},bg=${THEME[bblack]}] \
#{?#{==:#{pane_current_command},ssh},󰣀 ,$active_terminal_icon }\
#[fg=${THEME[bpurple]},bold,nodim]\
$window_number#W\
#[nobold]\
#{?window_zoomed_flag, $zoom_number, $custom_pane}\
#{?window_last_flag, ,}"

tmux set -g window-status-format "\
$RESET#[fg=${THEME[foreground]}] \
#{?#{==:#{pane_current_command},ssh},󰣀 ,$terminal_icon }\
${RESET}\
$window_number#W\
#[nobold,dim]\
#{?window_zoomed_flag, $zoom_number, $custom_pane}\
#[fg=${THEME[yellow]}]\
#{?window_last_flag, ,}"

# Public status components. Each option can be overridden in tmux.conf, or set
# to an empty string to disable that component. Use #{E:...} to expand a
# component in a status format, just like Catppuccin's status modules.
set_default_status_component() {
	local option="$1"
	local value="$2"

	tmux set-option -og "$option" "$value"
}

set_default_status_component @gruvbox-tmux_status_git \
	"#[fg=${THEME[ghgreen]},bg=${THEME[black]}]$git_status"
set_default_status_component @gruvbox-tmux_status_wb_git \
	"#[fg=${THEME[ghpurple]},bg=${THEME[black]}]$wb_git_status"
set_default_status_component @gruvbox-tmux_status_battery \
	"#[fg=${THEME[ghred]},bg=${THEME[black]}]$battery_status"
set_default_status_component @gruvbox-tmux_status_datetime \
	"#[fg=${THEME[ghyellow]},bg=${THEME[black]}]$date_and_time"
set_default_status_component @gruvbox-tmux_status_ssh \
	"#[fg=${THEME[ghcyan]},bg=${THEME[black]}]$ssh_connection_status"

# 1. Define your lookup dictionary
declare -A RIGHT_ITEM_TYPES=(
	[git]="@gruvbox-tmux_status_git"
	[wb_git]="@gruvbox-tmux_status_wb_git"
	[battery]="@gruvbox-tmux_status_battery"
	[datetime]="@gruvbox-tmux_status_datetime"
	[ssh]="@gruvbox-tmux_status_ssh"
)

DEFAULT_ITEMS="ssh git datetime"
tmux set-option -og @gruvbox-tmux_status_right_items "$DEFAULT_ITEMS"

# 3. Build the right status string dynamically
default_right_status=""
for key in $(tmux show-option -gv @gruvbox-tmux_status_right_items); do
	# Check if the key exists in the dictionary to avoid errors
	if [[ -n "${RIGHT_ITEM_TYPES[$key]}" ]]; then
		default_right_status="${default_right_status}#{E:${RIGHT_ITEM_TYPES[$key]}}"
	fi
done

tmux set-option -og @gruvbox-tmux_status_right "$default_right_status"

# Users can set @gruvbox-tmux_status_right before loading the plugin to
# compose/reorder modules. The theme expands that option into status-right.
tmux set -g status-right '#{E:@gruvbox-tmux_status_right}'

tmux set -g window-status-separator ""
