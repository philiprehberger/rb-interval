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
    def self.new(start, finish)
      Range.new(start, finish)
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

    # Find gaps between a collection of intervals.
    #
    # @param intervals [Array<Range>] the intervals to analyze
    # @return [Array<Range>] gaps between the merged intervals
    def self.gaps(intervals)
      merged = self.merge(intervals)
      return [] if merged.length < 2

      result = []
      merged.each_cons(2) do |a, b|
        result << Range.new(a.finish, b.start) if a.finish < b.start
      end
      result
    end
  end
end
