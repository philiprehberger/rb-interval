# frozen_string_literal: true

require_relative 'interval/version'
require_relative 'interval/range'

module Philiprehberger
  module Interval
    class Error < StandardError; end

    # Create a new interval.
    #
    # @param start [Comparable] the start value
    # @param finish [Comparable] the end value
    # @return [Range] a new interval
    def self.new(start, finish, type: :closed)
      Range.new(start, finish, type: type)
    end

    # Merge a collection of overlapping or adjacent intervals into non-overlapping intervals.
    #
    # @param intervals [Array<Range>] the intervals to merge
    # @return [Array<Range>] merged, sorted, non-overlapping intervals
    def self.merge(intervals)
      return [] if intervals.empty?

      sorted = intervals.sort
      merged = [sorted.first]

      sorted[1..].each do |current|
        last = merged.last
        combined = last.union(current)
        if combined
          merged[-1] = combined
        else
          merged << current
        end
      end

      merged
    end

    # Compute the common overlap across a collection of intervals.
    #
    # @param intervals [Array<Range>] the intervals to intersect
    # @return [Range, nil] the common intersection, or nil if any pair is disjoint
    def self.intersection(intervals)
      return nil if intervals.empty?

      intervals[1..].reduce(intervals.first) do |acc, current|
        return nil if acc.nil?

        acc.intersect(current)
      end
    end

    # Find gaps between a collection of intervals.
    #
    # @param intervals [Array<Range>] the intervals to analyze
    # @return [Array<Range>] gaps between the merged intervals
    def self.gaps(intervals)
      merged = merge(intervals)
      return [] if merged.length < 2

      result = []
      merged.each_cons(2) do |a, b|
        result << Range.new(a.finish, b.start) if a.finish < b.start
      end
      result
    end

    # The smallest closed interval that contains every input interval.
    #
    # The result spans from the minimum start to the maximum finish across
    # all inputs and is always returned as a closed interval. Distinct from
    # {.merge} (which yields multiple intervals when there are gaps) and
    # {.intersection} (which yields the common overlap or nil).
    #
    # @param intervals [Array<Range>] the intervals to span
    # @return [Range, nil] the enclosing interval, or `nil` if the input is empty
    def self.span(intervals)
      return nil if intervals.empty?

      min_start = intervals.map(&:start).min
      max_finish = intervals.map(&:finish).max
      Range.new(min_start, max_finish)
    end
  end
end
