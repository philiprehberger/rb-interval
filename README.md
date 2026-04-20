# philiprehberger-interval

[![Tests](https://github.com/philiprehberger/rb-interval/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-interval/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-interval.svg)](https://rubygems.org/gems/philiprehberger-interval)
[![Last updated](https://img.shields.io/github/last-commit/philiprehberger/rb-interval)](https://github.com/philiprehberger/rb-interval/commits/main)

Interval data type with open/closed boundaries, arithmetic, merging, and gap finding

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
a.overlap_ratio(b) # => 0.5
```

### Interval Types

Supports closed, open, and half-open boundaries:

```ruby
closed     = Philiprehberger::Interval.new(1, 5, type: :closed)     # [1, 5] (default)
open       = Philiprehberger::Interval.new(1, 5, type: :open)       # (1, 5)
left_open  = Philiprehberger::Interval.new(1, 5, type: :left_open)  # (1, 5]
right_open = Philiprehberger::Interval.new(1, 5, type: :right_open) # [1, 5)

closed.include?(5)      # => true
right_open.include?(5)  # => false
```

### Interval Arithmetic

```ruby
interval = Philiprehberger::Interval.new(2, 8)

interval.shift(3)                    # => [5, 11]
interval.scale(2, anchor: :left)     # => [2, 14]
interval.scale(0.5, anchor: :center) # => [3.5, 6.5]
interval.split(3)                    # => [[2, 4], [4, 6], [6, 8]]
interval.clamp(10)                   # => 8
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

### Sampling Random Values

Return one or more random Floats from within an interval. Open boundaries are respected via rejection sampling:

```ruby
interval = Philiprehberger::Interval.new(1.0, 5.0)
interval.sample        # => 3.247... (single Float)
interval.sample(3)     # => [1.823..., 4.501..., 2.964...]

open = Philiprehberger::Interval.new(1.0, 5.0, type: :open)
open.sample            # => always strictly between 1.0 and 5.0
```

### Finding a Common Intersection

Compute the overlap shared by every interval, or `nil` if any pair is disjoint:

```ruby
Philiprehberger::Interval.intersection([
  Philiprehberger::Interval.new(1, 10),
  Philiprehberger::Interval.new(3, 8),
  Philiprehberger::Interval.new(5, 12)
])
# => [5, 8]
```

### Touching Intervals

Check whether two intervals meet at exactly one point with no overlap and no gap — useful when partitioning a range so every value is covered exactly once:

```ruby
a = Philiprehberger::Interval.new(1, 5, type: :right_open) # [1, 5)
b = Philiprehberger::Interval.new(5, 10, type: :closed)    # [5, 10]
a.touching?(b) # => true  (5 covered once)

c = Philiprehberger::Interval.new(1, 5, type: :closed)     # [1, 5]
d = Philiprehberger::Interval.new(5, 10, type: :closed)    # [5, 10]
c.touching?(d) # => false (5 covered twice)
```

### With Time Values

```ruby
shift = Philiprehberger::Interval.new(Time.new(2026, 1, 1, 9), Time.new(2026, 1, 1, 17))
shift.include?(Time.new(2026, 1, 1, 12))  # => true
```

## API

| Method | Description |
|--------|-------------|
| `.new(start, finish, type:)` | Create an interval (`:closed`, `:open`, `:left_open`, `:right_open`) |
| `#type` | Return the interval boundary type |
| `#overlaps?(other)` | Check if two intervals overlap (respects boundary types) |
| `#contains?(other)` | Check if interval fully contains another |
| `#adjacent?(other)` | Check if intervals are touching but not overlapping |
| `#touching?(other)` | Check if intervals meet at a single point with exactly one closed side |
| `#intersect(other)` | Return the overlap between two intervals |
| `#overlap_ratio(other)` | Fraction of self covered by other (0.0–1.0) |
| `#union(other)` | Return the combined interval |
| `#subtract(other)` | Remove another interval, returning remaining parts |
| `#size` | Length of the interval |
| `#length` | Alias for `#size` |
| `#include?(point)` | Check if a point falls within the interval (respects boundary types) |
| `#shift(delta)` | Return new interval shifted by delta, preserving type |
| `#scale(factor, anchor:)` | Scale width around anchor (`:center`, `:left`, `:right`) |
| `#split(n)` | Split into n equal sub-intervals |
| `#clamp(value)` | Clamp value to interval bounds |
| `#sample(n = nil)` | Return a random Float, or array of n Floats, within the interval (respects boundaries) |
| `.merge(intervals)` | Merge overlapping intervals into non-overlapping set |
| `.gaps(intervals)` | Find gaps between a set of intervals |
| `.intersection(intervals)` | Common overlap of a collection of intervals, or `nil` |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## Support

If you find this project useful:

⭐ [Star the repo](https://github.com/philiprehberger/rb-interval)

🐛 [Report issues](https://github.com/philiprehberger/rb-interval/issues?q=is%3Aissue+is%3Aopen+label%3Abug)

💡 [Suggest features](https://github.com/philiprehberger/rb-interval/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement)

❤️ [Sponsor development](https://github.com/sponsors/philiprehberger)

🌐 [All Open Source Projects](https://philiprehberger.com/open-source-packages)

💻 [GitHub Profile](https://github.com/philiprehberger)

🔗 [LinkedIn Profile](https://www.linkedin.com/in/philiprehberger)

## License

[MIT](LICENSE)
