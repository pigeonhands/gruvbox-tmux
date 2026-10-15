#!/usr/bin/env bash

SHOW_SSH_CONNECTION=$(tmux show-option -gv @gruvbox-tmux_show_ssh 2>/dev/null)

TMUX_PANE_TTY="$1"
SHOW_SSH_CLIENT_CONNECTION="0"
SHOW_SSH_SERVER_CONNECTION="0"

case "$SHOW_SSH_CONNECTION" in
"both")
	SHOW_SSH_CLIENT_CONNECTION="1"
	SHOW_SSH_SERVER_CONNECTION="1"
	;;
"client")
	SHOW_SSH_CLIENT_CONNECTION="1"
	;;
"server")
	SHOW_SSH_SERVER_CONNECTION="1"
	;;
*)
	exit 0
	;;
esac

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."
. "${ROOT_DIR}/src/themes.sh" || {
	echo "Error: Failed to source themes.sh" >&2
	exit 1
}

SSH_ICON=$(tmux show-option -gv @gruvbox-tmux_ssh_icon 2>/dev/null)
SSH_USE_NERDFONT=$(tmux show-option -gv @gruvbox-tmux_ssh_use_nerdfont 2>/dev/null)

if [[ -z "$SSH_ICON" ]]; then
	if [[ "$SSH_USE_NERDFONT" == "1" ]]; then
		# SSH_ICON="󰌘"
		# SSH_ICON="󰛴"
		SSH_ICON="󰱠"
	else
		SSH_ICON="»"
	fi
fi

separator="#{E:@gruvbox-tmux-seperator}"

function display_ssh() {
	echo "$RESET#[fg=${THEME[baqua]},bg=${THEME[black]}]$separator $@ "
}

if [[ "$SHOW_SSH_SERVER_CONNECTION" == "1" ]] && [[ -n "$SSH_CONNECTION" ]]; then
	ssh_conn=$(echo "$SSH_CONNECTION" | awk -v icon="$SSH_ICON" '{ print $1 " " icon }')
	if [[ -n "$ssh_conn" ]]; then
		display_ssh "$ssh_conn" "#h"
	fi
fi

if [[ "$SHOW_SSH_CLIENT_CONNECTION" == "1" ]] && [[ -n "$TMUX_PANE_TTY" ]]; then
	tty_name="${TMUX_PANE_TTY#/dev/}"
	ssh_cmd="$(ps -o args= -t "$tty_name" 2>/dev/null | command grep -E '(^|\s)ssh(\s|$)' | head -n 1)"
	if [[ -n "$ssh_cmd" ]]; then
		display_ssh "$SSH_ICON" "$ssh_cmd"
	fi
fi
