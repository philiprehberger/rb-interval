# frozen_string_literal: true

module Philiprehberger
  module Interval
    VALID_TYPES = %i[closed open left_open right_open].freeze

    # Represents an interval over any Comparable type.
    # Supports closed [a, b], open (a, b), left-open (a, b], and right-open [a, b) boundaries.
    class Range
      include Comparable

      # @return [Comparable] the start of the interval
      attr_reader :start

      # @return [Comparable] the end of the interval
      attr_reader :finish

      # @return [Symbol] the interval type (:closed, :open, :left_open, :right_open)
      attr_reader :type

      # Create a new interval.
      #
      # @param start [Comparable] the start value
      # @param finish [Comparable] the end value
      # @param type [Symbol] boundary type (:closed, :open, :left_open, :right_open)
      # @raise [Error] if start > finish
      # @raise [Error] if type is invalid
      def initialize(start, finish, type: :closed)
        raise Error, 'start must be <= finish' if start > finish
        raise Error, "invalid interval type: #{type}" unless VALID_TYPES.include?(type)

        @start = start
        @finish = finish
        @type = type
      end

      # Check if this interval overlaps with another.
      #
      # @param other [Range] the other interval
      # @return [Boolean]
      def overlaps?(other)
        return false if empty? || other.empty?

        left_ok = if right_closed? && other.left_closed?
                    @finish >= other.start
                  else
                    @finish > other.start
                  end

        right_ok = if other.right_closed? && left_closed?
                     other.finish >= @start
                   else
                     other.finish > @start
                   end

        left_ok && right_ok
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

      # Return the fraction of self that is covered by another interval.
      #
      # Returns a Float in 0.0..1.0. Returns 0.0 if disjoint, 1.0 if self is
      # fully contained in other. If self has zero length (a point), returns
      # 1.0 when the point is within other, else 0.0.
      #
      # @param other [Range] the other interval
      # @return [Float] the fraction of self covered by other
      def overlap_ratio(other)
        return other.include?(@start) ? 1.0 : 0.0 if size.zero?

        overlap = intersect(other)
        return 0.0 if overlap.nil?

        overlap.size.to_f / size
      end

      # Check if a point is within the interval.
      #
      # @param point [Comparable] the point to check
      # @return [Boolean]
      def include?(point)
        left = left_closed? ? point >= @start : point > @start
        right = right_closed? ? point <= @finish : point < @finish
        left && right
      end

      # Return a new interval shifted by delta, preserving type.
      #
      # @param delta [Numeric] the amount to shift
      # @return [Range] a new shifted interval
      def shift(delta)
        self.class.new(@start + delta, @finish + delta, type: @type)
      end

      # Scale interval width around an anchor point, preserving type.
      #
      # @param factor [Numeric] the scale factor
      # @param anchor [Symbol] the anchor point (:center, :left, :right)
      # @return [Range] a new scaled interval
      def scale(factor, anchor: :center)
        current_size = size
        new_size = current_size * factor

        case anchor
        when :left
          self.class.new(@start, @start + new_size, type: @type)
        when :right
          self.class.new(@finish - new_size, @finish, type: @type)
        when :center
          center = @start + (current_size / 2.0)
          half = new_size / 2.0
          self.class.new(center - half, center + half, type: @type)
        else
          raise Error, "invalid anchor: #{anchor}"
        end
      end

      # Split interval into n equal sub-intervals, preserving type.
      #
      # @param n [Integer] number of sub-intervals
      # @return [Array<Range>] array of n equal sub-intervals
      def split(n)
        raise Error, 'n must be positive' if n < 1

        step = size.to_f / n
        Array.new(n) do |i|
          sub_start = @start + (step * i)
          sub_finish = @start + (step * (i + 1))
          self.class.new(sub_start, sub_finish, type: @type)
        end
      end

      # Return one or more random Floats within the interval.
      #
      # Without an argument, returns a single random Float. With an integer
      # argument, returns an array of that many random Floats. Respects boundary
      # types: open boundaries are excluded via rejection sampling. Returns
      # +start+ immediately for point intervals (start == finish, closed).
      #
      # @param n [Integer, nil] number of samples, or nil for a single value
      # @return [Float, Array<Float>]
      # @raise [Error] if the interval is empty
      def sample(n = nil)
        raise Error, 'cannot sample an empty interval' if empty?

        if n.nil?
          sample_one
        else
          Array.new(n) { sample_one }
        end
      end

      # Clamp a value to the interval bounds.
      #
      # @param value [Comparable] the value to clamp
      # @return [Comparable] the clamped value
      def clamp(value)
        return @start if value < @start
        return @finish if value > @finish

        value
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
        other.is_a?(self.class) && @start == other.start && @finish == other.finish && @type == other.type
      end

      # @return [String]
      def to_s
        left_bracket = left_closed? ? '[' : '('
        right_bracket = right_closed? ? ']' : ')'
        "#{left_bracket}#{@start}, #{@finish}#{right_bracket}"
      end

      # @return [String]
      def inspect
        "#<#{self.class} #{self}>"
      end

      # @return [Boolean] true if the left endpoint is included
      def left_closed?
        @type == :closed || @type == :right_open
      end

      # @return [Boolean] true if the right endpoint is included
      def right_closed?
        @type == :closed || @type == :left_open
      end

      protected

      # @return [Boolean] true if the interval contains no points
      def empty?
        @start == @finish && @type != :closed
      end

      private

      def sample_one
        return @start.to_f if @start == @finish

        lo = @start.to_f
        hi = @finish.to_f

        loop do
          value = lo + (rand * (hi - lo))
          left_ok  = left_closed?  ? value >= lo : value > lo
          right_ok = right_closed? ? value <= hi : value < hi
          return value if left_ok && right_ok
        end
      end
    end
  end
end
