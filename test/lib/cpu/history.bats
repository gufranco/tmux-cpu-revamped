#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  unset _CPU_REVAMPED_HISTORY_LOADED
  source "${BATS_TEST_DIRNAME}/../../../src/lib/cpu/history.sh"
}

teardown() {
  cleanup_test_environment
}

@test "history.sh - functions are defined" {
  function_exists cpu_sparkline
  function_exists cpu_history_push
  function_exists cpu_history_get
  function_exists cpu_render_graph
}

@test "history.sh - cpu_sparkline is empty for an empty list" {
  [[ -z "$(cpu_sparkline "")" ]]
}

@test "history.sh - cpu_sparkline maps values to the ramp" {
  [[ "$(cpu_sparkline "0 50 100")" == "▁▄█" ]]
}

@test "history.sh - cpu_sparkline clamps and zeroes junk" {
  [[ "$(cpu_sparkline "-5 200 abc")" == "▁█▁" ]]
}

@test "history.sh - cpu_sparkline strips a decimal part" {
  [[ "$(cpu_sparkline "99.9")" == "█" ]]
}

@test "history.sh - cpu_history_get is empty when unset" {
  [[ -z "$(cpu_history_get)" ]]
}

@test "history.sh - cpu_history_push appends an integer" {
  cpu_history_push 10
  [[ "$(cpu_history_get)" == "10" ]]
}

@test "history.sh - cpu_history_push drops a decimal part" {
  cpu_history_push "42.7"
  [[ "$(cpu_history_get)" == "42" ]]
}

@test "history.sh - cpu_history_push ignores a non-numeric value" {
  cpu_history_push 10
  cpu_history_push abc
  [[ "$(cpu_history_get)" == "10" ]]
}

@test "history.sh - cpu_history_push trims to the max width" {
  cpu_history_push 10 3
  cpu_history_push 20 3
  cpu_history_push 30 3
  cpu_history_push 40 3
  [[ "$(cpu_history_get)" == "20 30 40" ]]
}

@test "history.sh - cpu_history_push defaults a non-numeric max to 20" {
  local i
  for (( i = 1; i <= 25; i++ )); do
    cpu_history_push "${i}" bad
  done
  local out
  out=$(cpu_history_get)
  local -a a
  read -ra a <<< "${out}"
  [[ "${#a[@]}" -eq 20 ]]
  [[ "${a[0]}" == "6" ]]
}

@test "history.sh - cpu_render_graph is empty on cold start" {
  [[ -z "$(cpu_render_graph)" ]]
}

@test "history.sh - cpu_render_graph renders the stored history" {
  cpu_history_push 0
  cpu_history_push 100
  [[ "$(cpu_render_graph)" == "▁█" ]]
}
