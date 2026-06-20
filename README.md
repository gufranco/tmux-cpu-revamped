<div align="center">

<h1>tmux-cpu-revamped</h1>

**CPU load, temperature, and frequency in your tmux status bar, without ever blocking the render.**

[![Tests](https://github.com/gufranco/tmux-cpu-revamped/actions/workflows/tests.yml/badge.svg)](https://github.com/gufranco/tmux-cpu-revamped/actions/workflows/tests.yml) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

</div>

**11** placeholders · **2** platforms · **135** tests · **95%+** coverage

Reading CPU load means sampling over a short interval, slow enough to stutter a status bar that does it inline. This plugin moves the sampling off the render path. The status line reads a value cached in a tmux server user-option and returns instantly, while a detached worker re-samples in the background. No temp files are involved. All state lives in tmux options.

Built from [tmux-plugin-template](https://github.com/gufranco/tmux-plugin-template).

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

## Install

With [TPM](https://github.com/tmux-plugins/tpm), add to `~/.tmux.conf`:

```tmux
set -g @plugin 'gufranco/tmux-cpu-revamped'
set -g status-right '#{cpu_icon} #{cpu_percentage} #{cpu_temp}'
```

Then press `prefix + I` to install.

Manual install:

```bash
git clone https://github.com/gufranco/tmux-cpu-revamped ~/.tmux/plugins/tmux-cpu-revamped
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
| `@cpu_revamped_freq_format` | `%sMHz` | format for the CPU clock |
| `@cpu_revamped_load_format` | `%s` | format for the load average |
| `@cpu_revamped_enable_logging` | `0` | set to `1` to log diagnostics under `~/.tmux/cpu-revamped-logs` |

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
