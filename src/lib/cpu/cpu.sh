#!/usr/bin/env bash
#
# cpu.sh: CPU load and temperature acquisition.
#
# The parser functions are pure: they take command output as text and return a
# number, which is what makes them testable without real hardware. The reader
# functions perform the actual sampling and run only inside the background worker,
# so their cost never lands on the status render. The thin _read_* seams exist so
# tests can stub the host probes deterministically.

[[ -n "${_CPU_REVAMPED_CPU_LOADED:-}" ]] && return 0
_CPU_REVAMPED_CPU_LOADED=1

_CPU_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${_CPU_LIB_DIR}/../utils/platform.sh"
# shellcheck source=/dev/null
source "${_CPU_LIB_DIR}/../utils/has-command.sh"

# Seconds the Linux sampler waits between the two /proc/stat reads.
CPU_SAMPLE_INTERVAL="${CPU_SAMPLE_INTERVAL:-0.3}"

# _cpu_stat_total_idle LINE -> "<total> <idle>" parsed from a /proc/stat cpu line.
_cpu_stat_total_idle() {
  local line="${1}"
  local -a f
  read -ra f <<< "${line}"
  local total=0 i
  for (( i = 1; i < ${#f[@]}; i++ )); do
    [[ "${f[i]}" =~ ^[0-9]+$ ]] || continue
    total=$(( total + f[i] ))
  done
  local idle=$(( ${f[4]:-0} + ${f[5]:-0} ))
  echo "${total} ${idle}"
}

# cpu_pct_from_stat LINE1 LINE2 -> integer load percent across the interval.
cpu_pct_from_stat() {
  local t1 i1 t2 i2
  read -r t1 i1 <<< "$(_cpu_stat_total_idle "${1}")"
  read -r t2 i2 <<< "$(_cpu_stat_total_idle "${2}")"
  local dt=$(( t2 - t1 )) di=$(( i2 - i1 ))
  (( dt <= 0 )) && { echo 0; return 0; }
  local used=$(( dt - di ))
  (( used < 0 )) && used=0
  awk -v u="${used}" -v t="${dt}" 'BEGIN { printf "%.0f", (u / t) * 100 }'
}

# cpu_pct_from_top TEXT -> integer load percent from a macOS `top` CPU usage line.
cpu_pct_from_top() {
  local idle
  idle=$(printf '%s\n' "${1}" | grep -i "CPU usage" | tail -1 \
    | sed -E 's/.*[, ]([0-9.]+)%[[:space:]]*idle.*/\1/')
  [[ "${idle}" =~ ^[0-9.]+$ ]] || { echo 0; return 0; }
  awk -v i="${idle}" 'BEGIN { printf "%.0f", 100 - i }'
}

# cpu_temp_from_sensors TEXT -> integer Celsius from `sensors` output.
cpu_temp_from_sensors() {
  printf '%s\n' "${1}" \
    | grep -m1 -E 'Tctl|Package id 0|Core 0' \
    | grep -oE '\+[0-9]+' | head -1 | tr -d '+'
}

# cpu_temp_from_thermal MILLIDEG -> integer Celsius from a thermal-zone reading.
cpu_temp_from_thermal() {
  [[ "${1}" =~ ^[0-9]+$ ]] || { echo ""; return 0; }
  echo $(( ${1} / 1000 ))
}

# Host-probe seams. Tests override these to inject fixtures.
_read_proc_cpu_line() { grep -m1 '^cpu ' /proc/stat 2>/dev/null; }
_read_sensors() { sensors 2>/dev/null; }
_thermal_available() { [[ -r /sys/class/thermal/thermal_zone0/temp ]]; }
_read_thermal() { cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null; }
_read_top() { top -l2 -n0 2>/dev/null; }
_read_osx_temp() { osx-cpu-temp 2>/dev/null; }

# _sample_proc_cpu -> load percent from two spaced /proc/stat reads.
_sample_proc_cpu() {
  local l1 l2
  l1=$(_read_proc_cpu_line)
  sleep "${CPU_SAMPLE_INTERVAL}"
  l2=$(_read_proc_cpu_line)
  cpu_pct_from_stat "${l1}" "${l2}"
}

# read_cpu_percentage -> sample CPU load. Slow path, worker only.
read_cpu_percentage() {
  if is_linux; then
    _sample_proc_cpu
  elif is_macos && has_command top; then
    cpu_pct_from_top "$(_read_top)"
  else
    echo 0
  fi
}

# read_cpu_temp -> CPU temperature in Celsius, empty when no sensor is available.
read_cpu_temp() {
  if is_linux; then
    if has_command sensors; then
      cpu_temp_from_sensors "$(_read_sensors)"
    elif _thermal_available; then
      cpu_temp_from_thermal "$(_read_thermal)"
    fi
  elif is_macos && has_command osx-cpu-temp; then
    # osx-cpu-temp reads Intel SMC keys and returns 0.0 on Apple Silicon, where
    # no sudoless CPU temperature source exists. Treat a zero reading as absent.
    local t
    t=$(_read_osx_temp | grep -oE '[0-9.]+' | head -1)
    case "${t}" in
      ""|0|0.0|0.00) ;;
      *) echo "${t}" ;;
    esac
  fi
}

export -f _cpu_stat_total_idle
export -f cpu_pct_from_stat
export -f cpu_pct_from_top
export -f cpu_temp_from_sensors
export -f cpu_temp_from_thermal
export -f _read_proc_cpu_line
export -f _read_sensors
export -f _thermal_available
export -f _read_thermal
export -f _read_top
export -f _read_osx_temp
export -f _sample_proc_cpu
export -f read_cpu_percentage
export -f read_cpu_temp
