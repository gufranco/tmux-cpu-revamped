#!/usr/bin/env bash
#
# cpu.sh: command dispatcher for tmux-cpu-revamped.
#
# Each status placeholder runs this with a subcommand. The dispatcher triggers a
# guarded background refresh, then maps the cached raw value to the requested
# output. The slow sampling happens only inside the worker, off the render path.
#
# Usage:
#   cpu.sh percentage | icon | fg_color | bg_color
#   cpu.sh temp | temp_icon | temp_fg_color | temp_bg_color
#   cpu.sh refresh

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

export CACHE_PREFIX="cpu_revamped"
export PLUGIN_LOG_NS="cpu-revamped"

# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/utils/has-command.sh"
# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/utils/platform.sh"
# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/tmux/tmux-ops.sh"
# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/utils/cache.sh"
# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/cpu/cpu.sh"
# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/cpu/render.sh"

# cpu_max_age -> how many seconds a sample stays fresh.
cpu_max_age() {
  get_tmux_option "@cpu_revamped_interval" "5"
}

# cpu_refresh -> the worker: sample every metric once and cache it.
cpu_refresh() {
  cache_set percent "$(read_cpu_percentage)"
  cache_set temp "$(read_cpu_temp)"
  cache_set freq "$(read_cpu_freq)"
  cache_set load "$(read_load_average)"
  cache_set count "$(read_cpu_count)"
}

# cpu_tick -> trigger a guarded background refresh when the sample is stale.
cpu_tick() {
  cache_refresh_if_stale percent "$(cpu_max_age)" cpu_refresh
}

main() {
  local cmd="${1:-}"

  if [[ "${cmd}" == "refresh" ]]; then
    cpu_refresh
    return 0
  fi

  cpu_tick

  case "${cmd}" in
    percentage)    cpu_render_percentage "$(cache_get percent)" ;;
    icon)          cpu_render_icon "$(cache_get percent)" ;;
    fg_color)      cpu_render_fg "$(cache_get percent)" ;;
    bg_color)      cpu_render_bg "$(cache_get percent)" ;;
    temp)          cpu_render_temp "$(cache_get temp)" ;;
    temp_icon)     cpu_render_temp_icon "$(cache_get temp)" ;;
    temp_fg_color) cpu_render_temp_fg "$(cache_get temp)" ;;
    temp_bg_color) cpu_render_temp_bg "$(cache_get temp)" ;;
    freq)          cpu_render_freq "$(cache_get freq)" ;;
    load)          cpu_render_load "$(cache_get load)" ;;
    count)         cpu_render_count "$(cache_get count)" ;;
    *)             return 0 ;;
  esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
