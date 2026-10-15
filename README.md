# Gruvbox Tmux

Forked from [motaz-shokry/gruvbox-tmux](https://gitlab.com/motaz-shokry/gruvbox-tmux) to add a more flexible api


![Overview](screenshots/overview.png)

A clean  Tmux theme that  follow the [gruvbox](https://github.com/morhetz/gruvbox) colors, Inspired by [Tokyo Night Tmux](https://github.com/janoamaral/tokyo-night-tmux).

## Requirements

This theme has the following hard requirements:

- Any font from [Nerd Fonts](https://www.nerdfonts.com/) 
- [Bash](https://www.gnu.org/software/bash/)

The following are recommended for full support of all widgets and features:

- bc (for git widgets)
- jq, gh, glab (for git forges widgets)

## Installation using TPM

In your `tmux.conf` add :

```bash
set -g @plugin "https://gitlab.com/motaz-shokry/gruvbox-tmux"
```

## Configuration

Add these lines to your  `.tmux.conf`:

### Theme Flavor

```bash
set -g @gruvbox-tmux_theme "medium"  # medium | soft | Default is hard  
set -g @gruvbox-tmux_transparent 0   # 1 | 0
```

### Terminal icons

```bash
set -g @gruvbox-tmux_terminal_icon 
set -g @gruvbox-tmux_active_terminal_icon 
```

### Number styles


```bash
set -g @gruvbox-tmux_window_id_style hsquare  # hsquare | fsquare | sub | super | arabic | earabic
set -g @gruvbox-tmux_pane_id_style super      # hsquare | fsquare | sub | super | arabic | earabic
set -g @gruvbox-tmux_zoom_id_style dsquare    # hsquare | fsquare | sub | super | arabic | earabic
```

### Widgets

For widgets add following lines in you `.tmux.conf`

#### Default widgets

Set the layout of the default widgets
```bash
tmux set-option -og @gruvbox-tmux_status_right_items " ssh git wb_git battery datetime"
```
Defaults to `ssh git datetime`

#### Time widget

This widget is enabled by default. To disable it:

```bash
set -g @gruvbox-tmux_show_datetime 0
```

Time options

```bash
set -g @gruvbox-tmux_time_format 24H
```
##### Available Options
- `24H`: 18:30
- `12H`: 6:30 PM



#### SSH Widget

This widget is enabled by default. To disable it:

```bash
set -g @gruvbox-tmux_show_ssh_connection 0
```

SSH options

```bash
set -g @tmux_show_ssh_connection "server" # show connected address when tmux is running on remote machine over ssh
set -g @tmux_show_ssh_connection "client" # show ssh cmd when ssh is running in tmux
set -g @tmux_show_ssh_connection "both" # both client and server

set -g @gruvbox-tmux_ssh_use_nerdfont 1     # use default nerdfont connection icon, otherwise unicode icon
set -g @gruvbox-gruvbox-tmux_ssh_icon "->"  # set connection icon
```


#### Battery Widget

```bash
set -g @gruvbox-tmux_show_battery_widget 1     # 0 to disable
set -g @gruvbox-tmux_battery_name "BAT0"       # run `ls /sys/class/power_supply` to know
set -g @gruvbox-tmux_battery_low_threshold 25 
```


### Custom status components

The right side of the status bar is composed from named, overridable options.
Use `#{E:@gruvbox-tmux_status_<name>}` to include a component in a status
format. The built-in components are:

- `@gruvbox-tmux_status_git`
- `@gruvbox-tmux_status_wb_git`
- `@gruvbox-tmux_status_battery`
- `@gruvbox-tmux_status_datetime`

Override a component or set it to an empty string to disable it. You can also
compose and reorder the right side with `@gruvbox-tmux_status_right` before TPM
loads the plugin:

```tmux
set -g @gruvbox-tmux_status_right '#{E:@gruvbox-tmux_status_git}#{E:@gruvbox-tmux_status_datetime}'
```

To add your own segments, define a tmux option and expand it in the composition.
For example, a custom segment can be included alongside the built-in modules:

```tmux
set -g @my_status_segment '#[fg=colour7] my segment '
set -g @gruvbox-tmux_status_right '#{E:@gruvbox-tmux_status_git}#{E:@my_status_segment}#{E:@gruvbox-tmux_status_datetime}'
```

The theme only supplies the default composition when `@gruvbox-tmux_status_right`
has not already been set, so custom compositions can be configured before TPM.

### Snapshots

![Hard](screenshots/hard.png)
![Light](screenshots/light.png)
