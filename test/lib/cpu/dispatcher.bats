#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  unset _CPU_REVAMPED_CPU_LOADED _CPU_REVAMPED_RENDER_LOADED
  export CACHE_SYNC=1
  source "${BATS_TEST_DIRNAME}/../../../src/cpu.sh"
  read_cpu_percentage() { echo "77"; }
  read_cpu_temp() { echo "50"; }
}

teardown() {
  cleanup_test_environment
}

@test "cpu.sh dispatcher - functions are defined" {
  function_exists main
  function_exists cpu_refresh
  function_exists cpu_tick
  function_exists cpu_max_age
}

@test "cpu.sh dispatcher - cpu_max_age default is 5" {
  [[ "$(cpu_max_age)" == "5" ]]
}

@test "cpu.sh dispatcher - cpu_max_age honors the interval option" {
  set_tmux_option "@cpu_revamped_interval" "10"
  [[ "$(cpu_max_age)" == "10" ]]
}

@test "cpu.sh dispatcher - cpu_refresh caches load and temperature" {
  cpu_refresh
  [[ "$(cache_get percent)" == "77" ]]
  [[ "$(cache_get temp)" == "50" ]]
}

@test "cpu.sh dispatcher - refresh subcommand caches values" {
  main refresh
  [[ "$(cache_get percent)" == "77" ]]
}

@test "cpu.sh dispatcher - percentage subcommand renders the cached load" {
  run main percentage
  [[ "${output}" == "77%" ]]
}

@test "cpu.sh dispatcher - icon subcommand maps the cached load" {
  run main icon
  [[ "${output}" == "▰▰▱" ]]
}

@test "cpu.sh dispatcher - temp subcommand renders the cached temperature" {
  run main temp
  [[ "${output}" == "50°C" ]]
}

@test "cpu.sh dispatcher - fg_color maps the cached load" {
  set_tmux_option "@cpu_revamped_medium_fg_color" "#[fg=yellow]"
  run main fg_color
  [[ "${output}" == "#[fg=yellow]" ]]
}

@test "cpu.sh dispatcher - bg_color maps the cached load" {
  set_tmux_option "@cpu_revamped_medium_bg_color" "#[bg=yellow]"
  run main bg_color
  [[ "${output}" == "#[bg=yellow]" ]]
}

@test "cpu.sh dispatcher - temp_icon maps the cached temperature" {
  set_tmux_option "@cpu_revamped_temp_low_icon" "COOL"
  run main temp_icon
  [[ "${output}" == "COOL" ]]
}

@test "cpu.sh dispatcher - temp_fg_color maps the cached temperature" {
  set_tmux_option "@cpu_revamped_temp_low_fg_color" "#[fg=blue]"
  run main temp_fg_color
  [[ "${output}" == "#[fg=blue]" ]]
}

@test "cpu.sh dispatcher - temp_bg_color maps the cached temperature" {
  set_tmux_option "@cpu_revamped_temp_low_bg_color" "#[bg=blue]"
  run main temp_bg_color
  [[ "${output}" == "#[bg=blue]" ]]
}

@test "cpu.sh dispatcher - unknown subcommand produces no output" {
  run main bogus
  [[ -z "${output}" ]]
}
