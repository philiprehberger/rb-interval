# frozen_string_literal: true

module Philiprehberger
  module Interval
    # Represents a closed interval [start, finish] over any Comparable type.
    class Range
      include Comparable

      # @return [Comparable] the start of the interval
      attr_reader :start

      # @return [Comparable] the end of the interval
      attr_reader :finish

      # Create a new interval.
      #
      # @param start [Comparable] the start value
      # @param finish [Comparable] the end value
      # @raise [Error] if start > finish
      def initialize(start, finish)
        raise Error, 'start must be <= finish' if start > finish

        @start = start
        @finish = finish
      end

      # Check if this interval overlaps with another.
      #
      # @param other [Range] the other interval
      # @return [Boolean]
      def overlaps?(other)
        @start <= other.finish && other.start <= @finish
      end

      # Check if this interval fully contains another.
      #
      # @param other [Range] the other interval
      # @return [Boolean]
      def contains?(other)
        @start <= other.start && @finish >= other.finish
      end

      # Check if this interval is adjacent to another (touching but not overlapping).
      #
      # @param other [Range] the other interval
      # @return [Boolean]
      def adjacent?(other)
        @finish == other.start || other.finish == @start
      end

      # Return the intersection of two overlapping intervals.
      #
      # @param other [Range] the other interval
      # @return [Range, nil] the intersection, or nil if no overlap
      def intersect(other)
        return nil unless overlaps?(other)

        self.class.new([@start, other.start].max, [@finish, other.finish].min)
      end

      # Return the union of two overlapping or adjacent intervals.
      #
      # @param other [Range] the other interval
      # @return [Range, nil] the union, or nil if not overlapping/adjacent
      def union(other)
        return nil unless overlaps?(other) || adjacent?(other)

        self.class.new([@start, other.start].min, [@finish, other.finish].max)
      end

      # Subtract another interval from this one.
      #
      # @param other [Range] the interval to subtract
      # @return [Array<Range>] zero, one, or two remaining intervals
      def subtract(other)
        return [self.class.new(@start, @finish)] unless overlaps?(other)
        return [] if other.contains?(self)

        result = []
        result << self.class.new(@start, other.start) if @start < other.start
        result << self.class.new(other.finish, @finish) if other.finish < @finish
        result
      end

      # Return the size (length) of the interval.
      #
      # @return [Numeric] the difference between finish and start
      def size
        @finish - @start
      end

      # Check if a point is within the interval.
      #
      # @param point [Comparable] the point to check
      # @return [Boolean]
      def include?(point)
        point.between?(@start, @finish)
      end

      # Compare intervals by start then finish.
      #
      # @param other [Range]
      # @return [Integer]
      def <=>(other)
        result = @start <=> other.start
        result.zero? ? @finish <=> other.finish : result
      end

      # @return [Boolean]
      def ==(other)
        other.is_a?(self.class) && @start == other.start && @finish == other.finish
      end

      # @return [String]
      def to_s
        "[#{@start}, #{@finish}]"
      end

      # @return [String]
      def inspect
        "#<#{self.class} #{self}>"
      end
    end
  end
end
