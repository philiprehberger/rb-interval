# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.7.0] - 2026-05-01

### Added
- `Interval.span(intervals)` — return the smallest closed interval containing every input interval; complements `merge` (multiple intervals on gaps) and `intersection` (common overlap)

## [0.6.0] - 2026-04-21

### Added
- `Range#touching?` — strict boundary-touching predicate
- `Range#length` — alias for `#size`

### Fixed
- `bug_report.yml` — require Ruby version; add Gem version input per guide

## [0.5.0] - 2026-04-16

### Added
- `Range#sample(n = nil)` — return a random Float within the interval, or an array of n random Floats; respects open/closed boundaries via rejection sampling; raises on empty intervals; returns start for point intervals

## [0.4.0] - 2026-04-15

### Added
- `Range#overlap_ratio(other)` — fraction of self covered by another interval (Float in 0.0–1.0)

## [0.3.0] - 2026-04-15

### Added
- `Interval.intersection(intervals)` — compute the common overlap of a collection of intervals

## [0.2.0] - 2026-04-03

### Added
- Open, half-open interval types via `type:` parameter (`:closed`, `:open`, `:left_open`, `:right_open`)
- `shift` method for translating intervals
- `scale` method for resizing around an anchor point
- `split` method for dividing into equal sub-intervals
- `clamp` method for constraining values to interval bounds

## [0.1.6] - 2026-03-31

### Added
- Add GitHub issue templates, dependabot config, and PR template

## [0.1.5] - 2026-03-31

### Changed
- Standardize README badges, support section, and license format

## [0.1.4] - 2026-03-26

### Changed

- Add Sponsor badge and fix License link format in README

## [0.1.3] - 2026-03-24

### Fixed
- Fix README one-liner to remove trailing period

## [0.1.2] - 2026-03-24

### Fixed
- Remove inline comments from Development section to match template

## [0.1.1] - 2026-03-22

### Changed
- Update rubocop configuration for Windows compatibility

## [0.1.0] - 2026-03-22

### Added
- Initial release
- Closed interval data type with start and finish values
- Overlap detection, containment check, and adjacency test
- Intersection, union, and subtraction operations
- Point inclusion check and interval size
- Collection-level merge to combine overlapping intervals
- Gap finding between a set of intervals
- Support for any Comparable type (Numeric, Time, etc.)
