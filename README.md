# philiprehberger-interval

[![Tests](https://github.com/philiprehberger/rb-interval/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-interval/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-interval.svg)](https://rubygems.org/gems/philiprehberger-interval)
[![License](https://img.shields.io/github/license/philiprehberger/rb-interval)](LICENSE)

Interval data type with overlap detection, merging, and gap finding.

## Requirements

- Ruby >= 3.1

## Installation

Add to your Gemfile:

```ruby
gem "philiprehberger-interval"
```

Or install directly:

```bash
gem install philiprehberger-interval
```

## Usage

```ruby
require "philiprehberger/interval"

a = Philiprehberger::Interval.new(1, 5)
b = Philiprehberger::Interval.new(3, 8)

a.overlaps?(b)     # => true
a.intersect(b)     # => [3, 5]
a.union(b)         # => [1, 8]
a.include?(4)      # => true
```

### Merging Intervals

```ruby
intervals = [
  Philiprehberger::Interval.new(1, 5),
  Philiprehberger::Interval.new(3, 7),
  Philiprehberger::Interval.new(10, 15)
]
Philiprehberger::Interval.merge(intervals)
# => [[1, 7], [10, 15]]
```

### Finding Gaps

```ruby
Philiprehberger::Interval.gaps(intervals)
# => [[7, 10]]
```

### With Time Values

```ruby
shift = Philiprehberger::Interval.new(Time.new(2026, 1, 1, 9), Time.new(2026, 1, 1, 17))
shift.include?(Time.new(2026, 1, 1, 12))  # => true
```

## API

| Method | Description |
|--------|-------------|
| `.new(start, finish)` | Create a closed interval |
| `#overlaps?(other)` | Check if two intervals overlap |
| `#contains?(other)` | Check if interval fully contains another |
| `#adjacent?(other)` | Check if intervals are touching but not overlapping |
| `#intersect(other)` | Return the overlap between two intervals |
| `#union(other)` | Return the combined interval |
| `#subtract(other)` | Remove another interval, returning remaining parts |
| `#size` | Length of the interval |
| `#include?(point)` | Check if a point falls within the interval |
| `.merge(intervals)` | Merge overlapping intervals into non-overlapping set |
| `.gaps(intervals)` | Find gaps between a set of intervals |

## Development

```bash
bundle install
bundle exec rspec      # Run tests
bundle exec rubocop    # Check code style
```

## License

MIT
