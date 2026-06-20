#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  unset _CPU_REVAMPED_CPU_LOADED
  export CPU_SAMPLE_INTERVAL=0
  source "${BATS_TEST_DIRNAME}/../../../src/lib/cpu/cpu.sh"
}

teardown() {
  cleanup_test_environment
}

@test "cpu.sh - _cpu_stat_total_idle sums total and idle" {
  [[ "$(_cpu_stat_total_idle "cpu 100 0 50 800 50 0 0")" == "1000 850" ]]
}

@test "cpu.sh - _cpu_stat_total_idle skips non-numeric fields" {
  [[ "$(_cpu_stat_total_idle "cpu 100 x 50 800 50")" == "1000 850" ]]
}

@test "cpu.sh - cpu_pct_from_stat computes the interval load" {
  [[ "$(cpu_pct_from_stat "cpu 0 0 0 100 0" "cpu 0 0 50 150 0")" == "50" ]]
}

@test "cpu.sh - cpu_pct_from_stat returns 0 for a zero interval" {
  [[ "$(cpu_pct_from_stat "cpu 0 0 0 100 0" "cpu 0 0 0 100 0")" == "0" ]]
}

@test "cpu.sh - cpu_pct_from_top derives load from idle" {
  local txt="CPU usage: 5.0% user, 3.0% sys, 92.0% idle"
  [[ "$(cpu_pct_from_top "${txt}")" == "8" ]]
}

@test "cpu.sh - cpu_pct_from_top uses the last usage line" {
  local txt=$'CPU usage: 1.0% user, 1.0% sys, 98.0% idle\nCPU usage: 10.0% user, 10.0% sys, 80.0% idle'
  [[ "$(cpu_pct_from_top "${txt}")" == "20" ]]
}

@test "cpu.sh - cpu_pct_from_top returns 0 on malformed input" {
  [[ "$(cpu_pct_from_top "no usage here")" == "0" ]]
}

@test "cpu.sh - cpu_temp_from_sensors reads a Core temperature" {
  [[ "$(cpu_temp_from_sensors "Core 0:        +45.0°C  (high)")" == "45" ]]
}

@test "cpu.sh - cpu_temp_from_sensors reads a Tctl temperature" {
  [[ "$(cpu_temp_from_sensors "Tctl:          +60.0°C")" == "60" ]]
}

@test "cpu.sh - cpu_temp_from_sensors is empty with no match" {
  [[ -z "$(cpu_temp_from_sensors "fan1: 1200 RPM")" ]]
}

@test "cpu.sh - cpu_temp_from_thermal converts millidegrees" {
  [[ "$(cpu_temp_from_thermal "45000")" == "45" ]]
}

@test "cpu.sh - cpu_temp_from_thermal is empty for junk" {
  [[ -z "$(cpu_temp_from_thermal "abc")" ]]
}

@test "cpu.sh - _sample_proc_cpu spaces two reads" {
  local statef="${TEST_TMPDIR}/cnt"
  echo 0 > "${statef}"
  _read_proc_cpu_line() {
    local n
    n=$(cat "${statef}")
    n=$(( n + 1 ))
    echo "${n}" > "${statef}"
    if [[ "${n}" -eq 1 ]]; then echo "cpu 0 0 0 100 0"; else echo "cpu 0 0 50 150 0"; fi
  }
  sleep() { :; }
  [[ "$(_sample_proc_cpu)" == "50" ]]
}

@test "cpu.sh - read_cpu_percentage uses the Linux sampler" {
  _PLATFORM_OS_CACHE="Linux"
  _sample_proc_cpu() { echo "33"; }
  [[ "$(read_cpu_percentage)" == "33" ]]
}

@test "cpu.sh - read_cpu_percentage uses top on macOS" {
  _PLATFORM_OS_CACHE="Darwin"
  has_command() { return 0; }
  _read_top() { echo "CPU usage: 1.0% user, 9.0% sys, 90.0% idle"; }
  [[ "$(read_cpu_percentage)" == "10" ]]
}

@test "cpu.sh - read_cpu_percentage is 0 on macOS without top" {
  _PLATFORM_OS_CACHE="Darwin"
  has_command() { return 1; }
  [[ "$(read_cpu_percentage)" == "0" ]]
}

@test "cpu.sh - read_cpu_percentage is 0 on an unknown platform" {
  _PLATFORM_OS_CACHE="Plan9"
  [[ "$(read_cpu_percentage)" == "0" ]]
}

@test "cpu.sh - read_cpu_temp reads sensors on Linux" {
  _PLATFORM_OS_CACHE="Linux"
  has_command() { [[ "$1" == "sensors" ]]; }
  _read_sensors() { echo "Core 0: +50.0°C"; }
  [[ "$(read_cpu_temp)" == "50" ]]
}

@test "cpu.sh - read_cpu_temp falls back to a thermal zone" {
  _PLATFORM_OS_CACHE="Linux"
  has_command() { return 1; }
  _thermal_available() { return 0; }
  _read_thermal() { echo "55000"; }
  [[ "$(read_cpu_temp)" == "55" ]]
}

@test "cpu.sh - read_cpu_temp is empty when Linux has no sensor" {
  _PLATFORM_OS_CACHE="Linux"
  has_command() { return 1; }
  _thermal_available() { return 1; }
  [[ -z "$(read_cpu_temp)" ]]
}

@test "cpu.sh - read_cpu_temp reads osx-cpu-temp on macOS" {
  _PLATFORM_OS_CACHE="Darwin"
  has_command() { [[ "$1" == "osx-cpu-temp" ]]; }
  _read_osx_temp() { echo "CPU: 61.2 °C"; }
  [[ "$(read_cpu_temp)" == "61.2" ]]
}

@test "cpu.sh - read_cpu_temp is empty on macOS without a tool" {
  _PLATFORM_OS_CACHE="Darwin"
  has_command() { return 1; }
  [[ -z "$(read_cpu_temp)" ]]
}
