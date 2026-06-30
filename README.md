<div align="center">

<h1>tmux-cpu-revamped</h1>

**CPU load, temperature, and frequency in your tmux status bar, without ever blocking the render.**

[![Tests](https://github.com/tmux-revamped/tmux-cpu-revamped/actions/workflows/tests.yml/badge.svg)](https://github.com/tmux-revamped/tmux-cpu-revamped/actions/workflows/tests.yml) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE) [![Version](https://img.shields.io/badge/version-1.3.0-blue.svg)](CHANGELOG.md)

</div>

**18** placeholders · **2** platforms · **224** tests · **95%+** coverage

Reading CPU load means sampling over a short interval, slow enough to stutter a status bar that does it inline. This plugin moves the sampling off the render path. The status line reads a value cached in a tmux server user-option and returns instantly, while a detached worker re-samples in the background. No temp files are involved. All state lives in tmux options.

Built from [tmux-plugin-template](https://github.com/tmux-revamped/tmux-plugin-template).

<table>
<tr>
<td><strong>Non-blocking</strong><br>The status renders instantly from a cached tmux user-option while a background worker samples.</td>
<td><strong>No temp files</strong><br>Every piece of state lives in tmux server options, nothing on disk.</td>
</tr>
<tr>
<td><strong>Cross-platform</strong><br>Linux and macOS, Intel and Apple Silicon.</td>
<td><strong>Tested</strong><br>95%+ line coverage enforced in CI.</td>
</tr>
</table>

## Placeholders

Add any of these to `status-left` or `status-right`:

| Placeholder | Output |
|-------------|--------|
| `#{cpu_percentage}` | CPU load, for example `42%` |
| `#{cpu_icon}` | a tier icon for the current load |
| `#{cpu_fg_color}` | foreground color for the current load tier |
| `#{cpu_bg_color}` | background color for the current load tier |
| `#{cpu_temp}` | CPU temperature, for example `54°C` |
| `#{cpu_temp_icon}` | a tier icon for the current temperature |
| `#{cpu_temp_fg_color}` | foreground color for the temperature tier |
| `#{cpu_temp_bg_color}` | background color for the temperature tier |
| `#{cpu_freq}` | CPU clock, for example `4000MHz` |
| `#{cpu_load}` | 1-minute load average, for example `1.23` |
| `#{cpu_count}` | number of logical CPUs |
| `#{cpu_load5}` | 5-minute load average |
| `#{cpu_load15}` | 15-minute load average |
| `#{cpu_graph}` | history sparkline of recent load, for example `▁▂▄▆█` |
| `#{cpu_top_process}` | the busiest process by CPU, for example `node 42%` |
| `#{cpu_governor}` | the Linux CPU frequency governor, for example `performance` |
| `#{cpu_load_color}` | foreground color for load relative to core count |
| `#{cpu_alert}` | an alert glyph when load or temperature is high, empty otherwise |


## Install

With [TPM](https://github.com/tmux-plugins/tpm), add to `~/.tmux.conf`:

```tmux
set -g @plugin 'tmux-revamped/tmux-cpu-revamped'
set -g status-right '#{cpu_icon} #{cpu_percentage} #{cpu_temp}'
```

Then press `prefix + I` to install.

Manual install:

```bash
git clone https://github.com/tmux-revamped/tmux-cpu-revamped ~/.tmux/plugins/tmux-cpu-revamped
run-shell ~/.tmux/plugins/tmux-cpu-revamped/cpu-revamped.tmux
```

## Configuration

Every option is read live, so changing one and reloading tmux takes effect at the
next refresh.

| Option | Default | Meaning |
|--------|---------|---------|
| `@cpu_revamped_interval` | `5` | seconds a sample stays fresh before a background re-sample |
| `@cpu_revamped_percentage_format` | `%s%%` | printf format for the load value |
| `@cpu_revamped_medium_thresh` | `30` | load percent at which the tier becomes medium |
| `@cpu_revamped_high_thresh` | `80` | load percent at which the tier becomes high |
| `@cpu_revamped_low_icon` | `▰▱▱` | icon for the low tier |
| `@cpu_revamped_medium_icon` | `▰▰▱` | icon for the medium tier |
| `@cpu_revamped_high_icon` | `▰▰▰` | icon for the high tier |
| `@cpu_revamped_low_fg_color` | empty | foreground for the low tier |
| `@cpu_revamped_medium_fg_color` | empty | foreground for the medium tier |
| `@cpu_revamped_high_fg_color` | empty | foreground for the high tier |
| `@cpu_revamped_low_bg_color` | empty | background for the low tier |
| `@cpu_revamped_medium_bg_color` | empty | background for the medium tier |
| `@cpu_revamped_high_bg_color` | empty | background for the high tier |
| `@cpu_revamped_temp_unit` | `C` | `C` or `F` |
| `@cpu_revamped_temp_format` | `%s°C` | printf format for the temperature value |
| `@cpu_revamped_temp_medium_thresh` | `65` | degrees Celsius for the medium tier |
| `@cpu_revamped_temp_high_thresh` | `80` | degrees Celsius for the high tier |
| `@cpu_revamped_temp_low_icon` | empty | icon for the low temperature tier |
| `@cpu_revamped_temp_medium_icon` | empty | icon for the medium temperature tier |
| `@cpu_revamped_temp_high_icon` | empty | icon for the high temperature tier |
| `@cpu_revamped_temp_low_fg_color` | empty | foreground for the low temperature tier |
| `@cpu_revamped_temp_medium_fg_color` | empty | foreground for the medium temperature tier |
| `@cpu_revamped_temp_high_fg_color` | empty | foreground for the high temperature tier |
| `@cpu_revamped_temp_low_bg_color` | empty | background for the low temperature tier |
| `@cpu_revamped_temp_medium_bg_color` | empty | background for the medium temperature tier |
| `@cpu_revamped_temp_high_bg_color` | empty | background for the high temperature tier |
| `@cpu_revamped_freq_format` | `%sMHz` | format for the CPU clock |
| `@cpu_revamped_load_format` | `%s` | format for the load average |
| `@cpu_revamped_graph_width` | `20` | number of samples kept in the history ring buffer |
| `@cpu_revamped_load_medium_ratio` | `0.7` | per-core load ratio at which `#{cpu_load_color}` becomes medium |
| `@cpu_revamped_load_high_ratio` | `1.0` | per-core load ratio at which `#{cpu_load_color}` becomes high |
| `@cpu_revamped_alert_icon` | `!` | glyph shown by `#{cpu_alert}` when load or temperature is high |
| `@cpu_revamped_popup_key` | `C` | `prefix` key that opens the detail popup |
| `@cpu_revamped_popup_command` | `btop` | command run inside the detail popup |
| `@cpu_revamped_popup_width` | `80%` | detail popup width |
| `@cpu_revamped_popup_height` | `80%` | detail popup height |
| `@cpu_revamped_throttle_when_detached` | `0` | set to `1` to stop resampling when no client is attached |
| `@cpu_revamped_enable_logging` | `0` | set to `1` to log diagnostics under `~/.tmux/cpu-revamped-logs` |

## Detail popup

Press `prefix + C` to open a detail popup running `btop` (configurable). The popup
uses tmux `display-popup`, available on tmux 3.2 and newer; on older tmux it shows
a short message instead. Rebind or repoint it:

```tmux
set -g @cpu_revamped_popup_key 'C'
set -g @cpu_revamped_popup_command 'btop'
```

## Doctor

Run the dispatcher with `doctor` to see why a token may be empty on this host:

```bash
~/.tmux/plugins/tmux-cpu-revamped/src/cpu.sh doctor
```

It reports the platform, whether the popup is supported, the temperature source
that applies here, and which optional tools are installed.

## Theme color suggestions

The defaults use the 16 ANSI color names, which the active tmux theme remaps, so the plugin matches any theme out of the box; for exact hex matches copy one block below.

### Catppuccin Mocha

```tmux
set -g @cpu_revamped_low_fg_color '#[fg=#a6e3a1]'
set -g @cpu_revamped_medium_fg_color '#[fg=#f9e2af]'
set -g @cpu_revamped_high_fg_color '#[fg=#f38ba8]'
set -g @cpu_revamped_temp_low_fg_color '#[fg=#a6e3a1]'
set -g @cpu_revamped_temp_medium_fg_color '#[fg=#f9e2af]'
set -g @cpu_revamped_temp_high_fg_color '#[fg=#f38ba8]'
```

### Dracula

```tmux
set -g @cpu_revamped_low_fg_color '#[fg=#50fa7b]'
set -g @cpu_revamped_medium_fg_color '#[fg=#f1fa8c]'
set -g @cpu_revamped_high_fg_color '#[fg=#ff5555]'
set -g @cpu_revamped_temp_low_fg_color '#[fg=#50fa7b]'
set -g @cpu_revamped_temp_medium_fg_color '#[fg=#f1fa8c]'
set -g @cpu_revamped_temp_high_fg_color '#[fg=#ff5555]'
```

### Nord

```tmux
set -g @cpu_revamped_low_fg_color '#[fg=#a3be8c]'
set -g @cpu_revamped_medium_fg_color '#[fg=#ebcb8b]'
set -g @cpu_revamped_high_fg_color '#[fg=#bf616a]'
set -g @cpu_revamped_temp_low_fg_color '#[fg=#a3be8c]'
set -g @cpu_revamped_temp_medium_fg_color '#[fg=#ebcb8b]'
set -g @cpu_revamped_temp_high_fg_color '#[fg=#bf616a]'
```

### Gruvbox Dark

```tmux
set -g @cpu_revamped_low_fg_color '#[fg=#b8bb26]'
set -g @cpu_revamped_medium_fg_color '#[fg=#fabd2f]'
set -g @cpu_revamped_high_fg_color '#[fg=#fb4934]'
set -g @cpu_revamped_temp_low_fg_color '#[fg=#b8bb26]'
set -g @cpu_revamped_temp_medium_fg_color '#[fg=#fabd2f]'
set -g @cpu_revamped_temp_high_fg_color '#[fg=#fb4934]'
```

### Tokyo Night

```tmux
set -g @cpu_revamped_low_fg_color '#[fg=#9ece6a]'
set -g @cpu_revamped_medium_fg_color '#[fg=#e0af68]'
set -g @cpu_revamped_high_fg_color '#[fg=#f7768e]'
set -g @cpu_revamped_temp_low_fg_color '#[fg=#9ece6a]'
set -g @cpu_revamped_temp_medium_fg_color '#[fg=#e0af68]'
set -g @cpu_revamped_temp_high_fg_color '#[fg=#f7768e]'
```

### Solarized Dark

```tmux
set -g @cpu_revamped_low_fg_color '#[fg=#859900]'
set -g @cpu_revamped_medium_fg_color '#[fg=#b58900]'
set -g @cpu_revamped_high_fg_color '#[fg=#dc322f]'
set -g @cpu_revamped_temp_low_fg_color '#[fg=#859900]'
set -g @cpu_revamped_temp_medium_fg_color '#[fg=#b58900]'
set -g @cpu_revamped_temp_high_fg_color '#[fg=#dc322f]'
```

## Support by platform and architecture

| Metric | Linux (x86_64 and arm64) | macOS Intel | macOS Apple Silicon |
|--------|--------------------------|-------------|---------------------|
| CPU load | yes, `/proc/stat` delta | yes, `top` | yes, `top` |
| CPU temperature | yes, typed thermal zone, coretemp, then `sensors` | `osx-cpu-temp` or `istats` | no, see note |
| CPU frequency | yes, `/proc/cpuinfo` or scaling | `sysctl` | per-chip clock table |
| Load average and count | yes | yes | yes |

CPU temperature on Apple Silicon has no sudoless source. Both `osx-cpu-temp` and
`istats` return `0.0` there, validated on an Apple M3 Max, which the plugin treats
as no reading, so the temperature placeholders stay empty. The `istats` fallback
helps only Intel Macs, where you install it with `gem install iStats`. On an Intel
Mac you can also install `osx-cpu-temp` with `brew install osx-cpu-temp`. On Linux
install `lm-sensors` for the `sensors` fallback; typed thermal zones and coretemp
need no extra package.

Frequency on Apple Silicon is a documented per-chip maximum clock, not a live
reading, since there is no sudoless live frequency source. Any metric without a
source on the host renders empty rather than a misleading value.

## Development

```bash
make test    # bats suite
make lint    # shellcheck
make coverage  # kcov line coverage on Linux
```

## License

[MIT](LICENSE), copyright Gustavo Franco.
