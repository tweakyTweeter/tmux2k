#!/usr/bin/env bash

set -e

declare -r mode_indicator_placeholder="\#{tmux_mode_indicator}"

declare -r prefix_prompt_config='@mode_indicator_prefix_prompt'
declare -r copy_prompt_config='@mode_indicator_copy_prompt'
declare -r sync_prompt_config='@mode_indicator_sync_prompt'
declare -r empty_prompt_config='@mode_indicator_empty_prompt'
declare -r custom_prompt_config="@mode_indicator_custom_prompt"
declare -r prefix_mode_style_config='@mode_indicator_prefix_mode_style'
declare -r copy_mode_style_config='@mode_indicator_copy_mode_style'
declare -r sync_mode_style_config='@mode_indicator_sync_mode_style'
declare -r empty_mode_style_config='@mode_indicator_empty_mode_style'
declare -r custom_mode_style_config="@mode_indicator_custom_mode_style"
declare -r custom_lsep_style_config="@mode_indicator_custom_lsep_style"
declare -r custom_rsep_style_config="@mode_indicator_custom_rsep_style"
declare -r custom_sep_config="@mode_indicator_custom_sep"

tmux_option() {
  local -r option=$(tmux show-option -gqv "$1")
  local -r fallback="$2"
  echo "${option:-$fallback}"
}

indicator_style() {
  local -r style=$(tmux_option "$1" "$2")
  echo "${style:+#[${style//,/]#[}]}"
}

init_tmux_mode_indicator() {
  local -r \
    prefix_prompt=$(tmux_option "$prefix_prompt_config" " WAIT ") \
    copy_prompt=$(tmux_option "$copy_prompt_config" " COPY ") \
    sync_prompt=$(tmux_option "$sync_prompt_config" " SYNC ") \
    empty_prompt=$(tmux_option "$empty_prompt_config" " TMUX ") \
    prefix_style=$(indicator_style "$prefix_mode_style_config" "bg=blue,fg=black") \
    copy_style=$(indicator_style "$copy_mode_style_config" "bg=yellow,fg=black") \
    sync_style=$(indicator_style "$sync_mode_style_config" "bg=red,fg=black") \
    empty_style=$(indicator_style "$empty_mode_style_config" "bg=cyan,fg=black")
    prefix_lsep_style="#[fg=blue]"
    prefix_rsep_style="#[fg=blue]"
    copy_lsep_style="#[fg=yellow]"
    copy_rsep_style="#[fg=yellow]"
    sync_lsep_style="#[fg=red]"
    sync_rsep_style="#[fg=red]"
    empty_lsep_style="#[fg=cyan]"
    empty_rsep_style="#[fg=cyan]"

  local -r \
    custom_prompt="#(tmux show-option -qv $custom_prompt_config)" \
    custom_style="#(tmux show-option -qv $custom_mode_style_config)"
    custom_lsep_style="#(tmux show-option -qv $custom_lsep_style_config)"
    custom_rsep_style="#(tmux show-option -qv $custom_rsep_style_config)"


  local -r \
    mode_prompt="#{?#{!=:$custom_prompt,},$custom_prompt,#{?client_prefix,$prefix_prompt,#{?pane_in_mode,$copy_prompt,#{?pane_synchronized,$sync_prompt,$empty_prompt}}}}"
    mode_style="#{?#{!=:$custom_style,},#[$custom_style],#{?client_prefix,$prefix_style,#{?pane_in_mode,$copy_style,#{?pane_synchronized,$sync_style,$empty_style}}}}"
    mode_lsep_style="#{?#{!=:$custom_lsep_style,},#[$custom_lsep_style],#{?client_prefix,$prefix_lsep_style,#{?pane_in_mode,$copy_lsep_style,#{?pane_synchronized,$sync_lsep_style,$empty_lsep_style}}}}"
    mode_rsep_style="#{?#{!=:$custom_rsep_style,},#[$custom_rsep_style],#{?client_prefix,$prefix_rsep_style,#{?pane_in_mode,$copy_rsep_style,#{?pane_synchronized,$sync_rsep_style,$empty_rsep_style}}}}"


  if $custom_sep_config; then  
  	local -r mode_indicator="$mode_lsep_style#[default]$mode_style$mode_prompt#[default]$mode_rsep_style"
  else
  	local -r mode_indicator="$mode_prompt"
  fi

  local -r status_left_value="$(tmux_option "status-left")"

  echo "$mode_indicator"

  #tmux set-option -gq "status-left" "${status_left_value/$mode_indicator_placeholder/$mode_indicator}"
  
  #local -r status_right_value="$(tmux_option "status-right")"
  #tmux set-option -gq "status-right" "${status_right_value/$mode_indicator_placeholder/$mode_indicator}"
}

init_tmux_mode_indicator
