#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  unset _CPU_REVAMPED_RENDER_LOADED
  source "${BATS_TEST_DIRNAME}/../../../src/lib/cpu/render.sh"
}

teardown() {
  cleanup_test_environment
}

@test "render.sh - _cpu_level classifies low, medium, high" {
  [[ "$(_cpu_level 10 30 80)" == "low" ]]
  [[ "$(_cpu_level 50 30 80)" == "medium" ]]
  [[ "$(_cpu_level 90 30 80)" == "high" ]]
}

@test "render.sh - _cpu_level treats non-numeric as zero" {
  [[ "$(_cpu_level abc 30 80)" == "low" ]]
}

@test "render.sh - _cpu_level strips a decimal part" {
  [[ "$(_cpu_level 85.9 30 80)" == "high" ]]
}

@test "render.sh - _cpu_c_to_f converts Celsius" {
  [[ "$(_cpu_c_to_f 50)" == "122" ]]
}

@test "render.sh - _cpu_c_to_f is empty for junk" {
  [[ -z "$(_cpu_c_to_f xx)" ]]
}

@test "render.sh - cpu_render_percentage is empty on cold start" {
  [[ -z "$(cpu_render_percentage "")" ]]
}

@test "render.sh - cpu_render_percentage uses the default format" {
  [[ "$(cpu_render_percentage 42)" == "42%" ]]
}

@test "render.sh - cpu_render_percentage honors a custom format" {
  set_tmux_option "@cpu_revamped_percentage_format" "[%s]"
  [[ "$(cpu_render_percentage 42)" == "[42]" ]]
}

@test "render.sh - cpu_render_icon picks the level icon" {
  [[ "$(cpu_render_icon 90)" == "▰▰▰" ]]
  [[ "$(cpu_render_icon 50)" == "▰▰▱" ]]
  [[ "$(cpu_render_icon 5)" == "▰▱▱" ]]
}

@test "render.sh - cpu_render_icon honors a custom icon" {
  set_tmux_option "@cpu_revamped_high_icon" "HOT"
  [[ "$(cpu_render_icon 95)" == "HOT" ]]
}

@test "render.sh - cpu_render_fg is empty by default" {
  [[ -z "$(cpu_render_fg 95)" ]]
}

@test "render.sh - cpu_render_fg returns the configured color" {
  set_tmux_option "@cpu_revamped_high_fg_color" "#[fg=red]"
  [[ "$(cpu_render_fg 95)" == "#[fg=red]" ]]
}

@test "render.sh - cpu_render_bg returns the configured color" {
  set_tmux_option "@cpu_revamped_low_bg_color" "#[bg=green]"
  [[ "$(cpu_render_bg 5)" == "#[bg=green]" ]]
}

@test "render.sh - cpu_render_temp is empty on cold start" {
  [[ -z "$(cpu_render_temp "")" ]]
}

@test "render.sh - cpu_render_temp formats Celsius by default" {
  [[ "$(cpu_render_temp 50)" == "50°C" ]]
}

@test "render.sh - cpu_render_temp converts to Fahrenheit" {
  set_tmux_option "@cpu_revamped_temp_unit" "F"
  [[ "$(cpu_render_temp 50)" == "122°F" ]]
}

@test "render.sh - cpu_render_temp_icon is empty on cold start" {
  [[ -z "$(cpu_render_temp_icon "")" ]]
}

@test "render.sh - cpu_render_temp_icon picks the level icon" {
  set_tmux_option "@cpu_revamped_temp_high_icon" "HOT"
  [[ "$(cpu_render_temp_icon 95)" == "HOT" ]]
}

@test "render.sh - cpu_render_temp_fg returns the configured color" {
  set_tmux_option "@cpu_revamped_temp_high_fg_color" "#[fg=red]"
  [[ "$(cpu_render_temp_fg 95)" == "#[fg=red]" ]]
}

@test "render.sh - cpu_render_temp_bg returns the configured color" {
  set_tmux_option "@cpu_revamped_temp_low_bg_color" "#[bg=blue]"
  [[ "$(cpu_render_temp_bg 40)" == "#[bg=blue]" ]]
}

@test "render.sh - cpu_render_temp_fg is empty on cold start" {
  [[ -z "$(cpu_render_temp_fg "")" ]]
}

@test "render.sh - cpu_render_freq is empty on cold start or zero" {
  [[ -z "$(cpu_render_freq "")" ]]
  [[ -z "$(cpu_render_freq 0)" ]]
}

@test "render.sh - cpu_render_freq formats with default and custom" {
  [[ "$(cpu_render_freq 4000)" == "4000MHz" ]]
  set_tmux_option "@cpu_revamped_freq_format" "%s MHz"
  [[ "$(cpu_render_freq 4000)" == "4000 MHz" ]]
}

@test "render.sh - cpu_render_load formats with default and custom" {
  [[ -z "$(cpu_render_load "")" ]]
  [[ "$(cpu_render_load 1.23)" == "1.23" ]]
  set_tmux_option "@cpu_revamped_load_format" "load %s"
  [[ "$(cpu_render_load 1.23)" == "load 1.23" ]]
}

@test "render.sh - cpu_render_count echoes the value" {
  [[ "$(cpu_render_count 12)" == "12" ]]
}
