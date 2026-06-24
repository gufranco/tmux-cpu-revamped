# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-06-23

### Added

- AMD Ryzen CPU temperature now reads directly from the `k10temp` hwmon sensor,
  preferring the Tctl die reading, so the temperature shows up even when
  `lm-sensors` is not installed.

### Changed

- Reviewed the upstream `tmux-plugins/tmux-cpu` open issues and pull requests.
  Confirmed the time formatting uses no GNU-only `date` flags (PR #97), and
  widened the temperature path to cover Ryzen without `sensors` (PR #81).

## [1.1.0] - 2026-06-20

### Added

- CPU frequency placeholder `#{cpu_freq}` with a per-chip clock table on Apple
  Silicon, `sysctl` on Intel macOS, and `/proc/cpuinfo` or scaling on Linux.
- Load-average placeholder `#{cpu_load}` and CPU-count placeholder `#{cpu_count}`.
- macOS CPU temperature via `istats` as a fallback to `osx-cpu-temp`.
- Richer Linux temperature: typed thermal zones, coretemp hwmon, and more
  `sensors` labels (Tdie, k10temp, CPU Temperature).

## [1.0.0] - 2026-06-19

### Added

- CPU load placeholders: `#{cpu_percentage}`, `#{cpu_icon}`, `#{cpu_fg_color}`,
  `#{cpu_bg_color}`.
- CPU temperature placeholders: `#{cpu_temp}`, `#{cpu_temp_icon}`,
  `#{cpu_temp_fg_color}`, `#{cpu_temp_bg_color}`.
- Non-blocking design: load is sampled in a background worker and read from a
  tmux user-option, so the status render never waits and no temp files are used.
- macOS load via `top`, Linux load via a `/proc/stat` delta.
- Temperature via `osx-cpu-temp` on macOS and `sensors` or a thermal zone on
  Linux, rendering empty when no sensor is present.
- Configurable thresholds, icons, colors, format strings, and Celsius or
  Fahrenheit units.
