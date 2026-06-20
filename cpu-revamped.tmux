#!/usr/bin/env bash
#
# cpu-revamped.tmux: TPM entry point.
#
# Replaces the #{cpu_*} placeholders in status-left and status-right with calls
# to the dispatcher. The dispatcher reads cached values, so the status render
# never blocks on a CPU sample.

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CPU_CMD="${PLUGIN_DIR}/src/cpu.sh"

placeholders=(
  "\#{cpu_percentage}"
  "\#{cpu_icon}"
  "\#{cpu_fg_color}"
  "\#{cpu_bg_color}"
  "\#{cpu_temp}"
  "\#{cpu_temp_icon}"
  "\#{cpu_temp_fg_color}"
  "\#{cpu_temp_bg_color}"
)

commands=(
  "#(${CPU_CMD} percentage)"
  "#(${CPU_CMD} icon)"
  "#(${CPU_CMD} fg_color)"
  "#(${CPU_CMD} bg_color)"
  "#(${CPU_CMD} temp)"
  "#(${CPU_CMD} temp_icon)"
  "#(${CPU_CMD} temp_fg_color)"
  "#(${CPU_CMD} temp_bg_color)"
)

interpolate() {
  local value="${1}"
  local i
  for (( i = 0; i < ${#placeholders[@]}; i++ )); do
    value="${value//${placeholders[i]}/${commands[i]}}"
  done
  echo "${value}"
}

update_option() {
  local option="${1}"
  local current
  current=$(tmux show-option -gqv "${option}")
  tmux set-option -gq "${option}" "$(interpolate "${current}")"
}

chmod +x "${CPU_CMD}" 2>/dev/null || true

update_option "status-left"
update_option "status-right"
