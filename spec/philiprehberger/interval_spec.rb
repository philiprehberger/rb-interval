# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::Interval do
  describe 'VERSION' do
    it 'has a version number' do
      expect(Philiprehberger::Interval::VERSION).not_to be_nil
    end
  end

  describe '.new' do
    it 'creates an interval' do
      interval = described_class.new(1, 5)
      expect(interval.start).to eq(1)
      expect(interval.finish).to eq(5)
    end

    it 'raises when start > finish' do
      expect { described_class.new(5, 1) }.to raise_error(Philiprehberger::Interval::Error)
    end

    it 'allows start == finish (point interval)' do
      interval = described_class.new(3, 3)
      expect(interval.size).to eq(0)
    end
  end

  describe '#overlaps?' do
    it 'returns true for overlapping intervals' do
      a = described_class.new(1, 5)
      b = described_class.new(3, 7)
      expect(a.overlaps?(b)).to be true
    end

    it 'returns true for contained intervals' do
      a = described_class.new(1, 10)
      b = described_class.new(3, 7)
      expect(a.overlaps?(b)).to be true
    end

    it 'returns true for touching intervals' do
      a = described_class.new(1, 5)
      b = described_class.new(5, 10)
      expect(a.overlaps?(b)).to be true
    end

    it 'returns false for non-overlapping intervals' do
      a = described_class.new(1, 3)
      b = described_class.new(5, 7)
      expect(a.overlaps?(b)).to be false
    end
  end

  describe '#contains?' do
    it 'returns true when interval fully contains another' do
      a = described_class.new(1, 10)
      b = described_class.new(3, 7)
      expect(a.contains?(b)).to be true
    end

    it 'returns true for identical intervals' do
      a = described_class.new(1, 5)
      b = described_class.new(1, 5)
      expect(a.contains?(b)).to be true
    end

    it 'returns false when interval does not contain another' do
      a = described_class.new(1, 5)
      b = described_class.new(3, 7)
      expect(a.contains?(b)).to be false
    end
  end

  describe '#adjacent?' do
    it 'returns true for adjacent intervals' do
      a = described_class.new(1, 5)
      b = described_class.new(5, 10)
      expect(a.adjacent?(b)).to be true
    end

    it 'returns false for non-adjacent intervals' do
      a = described_class.new(1, 3)
      b = described_class.new(5, 7)
      expect(a.adjacent?(b)).to be false
    end

    it 'returns false for overlapping intervals' do
      a = described_class.new(1, 5)
      b = described_class.new(3, 7)
      expect(a.adjacent?(b)).to be false
    end
  end

  describe '#intersect' do
    it 'returns intersection of overlapping intervals' do
      a = described_class.new(1, 5)
      b = described_class.new(3, 7)
      result = a.intersect(b)
      expect(result.start).to eq(3)
      expect(result.finish).to eq(5)
    end

    it 'returns nil for non-overlapping intervals' do
      a = described_class.new(1, 3)
      b = described_class.new(5, 7)
      expect(a.intersect(b)).to be_nil
    end

    it 'returns point interval for touching intervals' do
      a = described_class.new(1, 5)
      b = described_class.new(5, 10)
      result = a.intersect(b)
      expect(result.start).to eq(5)
      expect(result.finish).to eq(5)
    end
  end

  describe '#union' do
    it 'returns union of overlapping intervals' do
      a = described_class.new(1, 5)
      b = described_class.new(3, 7)
      result = a.union(b)
      expect(result.start).to eq(1)
      expect(result.finish).to eq(7)
    end

    it 'returns union of adjacent intervals' do
      a = described_class.new(1, 5)
      b = described_class.new(5, 10)
      result = a.union(b)
      expect(result.start).to eq(1)
      expect(result.finish).to eq(10)
    end

    it 'returns nil for non-overlapping non-adjacent intervals' do
      a = described_class.new(1, 3)
      b = described_class.new(5, 7)
      expect(a.union(b)).to be_nil
    end
  end

  describe '#subtract' do
    it 'returns empty array when other fully contains self' do
      a = described_class.new(3, 7)
      b = described_class.new(1, 10)
      expect(a.subtract(b)).to eq([])
    end

    it 'returns self when no overlap' do
      a = described_class.new(1, 3)
      b = described_class.new(5, 7)
      result = a.subtract(b)
      expect(result.length).to eq(1)
      expect(result.first.start).to eq(1)
      expect(result.first.finish).to eq(3)
    end

    it 'returns left remainder' do
      a = described_class.new(1, 7)
      b = described_class.new(5, 10)
      result = a.subtract(b)
      expect(result.length).to eq(1)
      expect(result.first.start).to eq(1)
      expect(result.first.finish).to eq(5)
    end

    it 'returns right remainder' do
      a = described_class.new(3, 10)
      b = described_class.new(1, 5)
      result = a.subtract(b)
      expect(result.length).to eq(1)
      expect(result.first.start).to eq(5)
      expect(result.first.finish).to eq(10)
    end

    it 'returns two intervals when punching a hole' do
      a = described_class.new(1, 10)
      b = described_class.new(4, 6)
      result = a.subtract(b)
      expect(result.length).to eq(2)
      expect(result[0].start).to eq(1)
      expect(result[0].finish).to eq(4)
      expect(result[1].start).to eq(6)
      expect(result[1].finish).to eq(10)
    end
  end

  describe '#overlap_ratio' do
    it 'returns 1.0 when self is fully contained in other' do
      a = described_class.new(3, 7)
      b = described_class.new(1, 10)
      expect(a.overlap_ratio(b)).to eq(1.0)
    end

    it 'returns 1.0 for identical intervals' do
      a = described_class.new(1, 5)
      b = described_class.new(1, 5)
      expect(a.overlap_ratio(b)).to eq(1.0)
    end

    it 'returns 0.0 for disjoint intervals' do
      a = described_class.new(1, 3)
      b = described_class.new(5, 7)
      expect(a.overlap_ratio(b)).to eq(0.0)
    end

    it 'returns 0.5 for half overlap' do
      a = described_class.new(0, 10)
      b = described_class.new(5, 15)
      expect(a.overlap_ratio(b)).to eq(0.5)
    end

    it 'returns 1.0 when self is a point within other' do
      a = described_class.new(3, 3)
      b = described_class.new(1, 5)
      expect(a.overlap_ratio(b)).to eq(1.0)
    end

    it 'returns 0.0 when self is a point outside other' do
      a = described_class.new(7, 7)
      b = described_class.new(1, 5)
      expect(a.overlap_ratio(b)).to eq(0.0)
    end
  end

  describe '#size' do
    it 'returns the length of the interval' do
      expect(described_class.new(1, 5).size).to eq(4)
    end

    it 'returns zero for point interval' do
      expect(described_class.new(3, 3).size).to eq(0)
    end
  end

  describe '#length' do
    it 'is an alias for #size on a closed interval' do
      interval = described_class.new(1, 5)
      expect(interval.length).to eq(interval.size)
      expect(interval.length).to eq(4)
    end

    it 'matches #size for an open interval' do
      interval = described_class.new(1, 5, type: :open)
      expect(interval.length).to eq(interval.size)
    end

    it 'matches #size for a left_open interval' do
      interval = described_class.new(2, 10, type: :left_open)
      expect(interval.length).to eq(interval.size)
      expect(interval.length).to eq(8)
    end

    it 'matches #size for a right_open interval' do
      interval = described_class.new(2, 10, type: :right_open)
      expect(interval.length).to eq(interval.size)
    end

    it 'returns zero for a point interval' do
      expect(described_class.new(3, 3).length).to eq(0)
    end
  end

  describe '#touching?' do
    it 'returns true when right_open meets closed at a point' do
      a = described_class.new(1, 5, type: :right_open)
      b = described_class.new(5, 10, type: :closed)
      expect(a.touching?(b)).to be true
    end

    it 'returns true when closed meets left_open at a point' do
      a = described_class.new(1, 5, type: :closed)
      b = described_class.new(5, 10, type: :left_open)
      expect(a.touching?(b)).to be true
    end

    it 'returns true in the reverse direction (other.finish == self.start)' do
      a = described_class.new(5, 10, type: :closed)
      b = described_class.new(1, 5, type: :right_open)
      expect(a.touching?(b)).to be true
    end

    it 'returns false when both endpoints are closed (point covered twice)' do
      a = described_class.new(1, 5, type: :closed)
      b = described_class.new(5, 10, type: :closed)
      expect(a.touching?(b)).to be false
    end

    it 'returns false when both endpoints are open (point not covered)' do
      a = described_class.new(1, 5, type: :right_open)
      b = described_class.new(5, 10, type: :left_open)
      expect(a.touching?(b)).to be false
    end

    it 'returns false for a gap between intervals' do
      a = described_class.new(1, 5)
      b = described_class.new(6, 10)
      expect(a.touching?(b)).to be false
    end

    it 'returns false for overlapping intervals' do
      a = described_class.new(1, 7)
      b = described_class.new(5, 10)
      expect(a.touching?(b)).to be false
    end
  end

  describe '#include?' do
    it 'returns true for point inside interval' do
      expect(described_class.new(1, 5).include?(3)).to be true
    end

    it 'returns true for start point' do
      expect(described_class.new(1, 5).include?(1)).to be true
    end

    it 'returns true for end point' do
      expect(described_class.new(1, 5).include?(5)).to be true
    end

    it 'returns false for point outside interval' do
      expect(described_class.new(1, 5).include?(7)).to be false
    end
  end

  describe '#==' do
    it 'returns true for equal intervals' do
      expect(described_class.new(1, 5)).to eq(described_class.new(1, 5))
    end

    it 'returns false for different intervals' do
      expect(described_class.new(1, 5)).not_to eq(described_class.new(1, 6))
    end
  end

  describe '#to_s' do
    it 'formats as [start, finish]' do
      expect(described_class.new(1, 5).to_s).to eq('[1, 5]')
    end
  end

  describe '.merge' do
    it 'returns empty array for empty input' do
      expect(described_class.merge([])).to eq([])
    end

    it 'merges overlapping intervals' do
      intervals = [described_class.new(1, 5), described_class.new(3, 7), described_class.new(6, 10)]
      result = described_class.merge(intervals)
      expect(result.length).to eq(1)
      expect(result.first.start).to eq(1)
      expect(result.first.finish).to eq(10)
    end

    it 'keeps non-overlapping intervals separate' do
      intervals = [described_class.new(1, 3), described_class.new(5, 7)]
      result = described_class.merge(intervals)
      expect(result.length).to eq(2)
    end

    it 'merges adjacent intervals' do
      intervals = [described_class.new(1, 5), described_class.new(5, 10)]
      result = described_class.merge(intervals)
      expect(result.length).to eq(1)
      expect(result.first.start).to eq(1)
      expect(result.first.finish).to eq(10)
    end

    it 'handles unsorted input' do
      intervals = [described_class.new(5, 10), described_class.new(1, 5)]
      result = described_class.merge(intervals)
      expect(result.length).to eq(1)
    end
  end

  describe '.gaps' do
    it 'returns empty array for empty input' do
      expect(described_class.gaps([])).to eq([])
    end

    it 'returns empty array for single interval' do
      expect(described_class.gaps([described_class.new(1, 5)])).to eq([])
    end

    it 'finds gaps between intervals' do
      intervals = [described_class.new(1, 3), described_class.new(5, 7), described_class.new(10, 12)]
      result = described_class.gaps(intervals)
      expect(result.length).to eq(2)
      expect(result[0].start).to eq(3)
      expect(result[0].finish).to eq(5)
      expect(result[1].start).to eq(7)
      expect(result[1].finish).to eq(10)
    end

    it 'returns empty array when intervals are contiguous' do
      intervals = [described_class.new(1, 5), described_class.new(5, 10)]
      expect(described_class.gaps(intervals)).to eq([])
    end
  end

  describe '.intersection' do
    it 'returns nil for empty input' do
      expect(described_class.intersection([])).to be_nil
    end

    it 'returns the single interval for a single-element input' do
      i = described_class.new(1, 5)
      expect(described_class.intersection([i])).to eq(i)
    end

    it 'computes the common overlap of multiple intervals' do
      result = described_class.intersection([
                                              described_class.new(1, 10),
                                              described_class.new(3, 8),
                                              described_class.new(5, 12)
                                            ])
      expect(result.start).to eq(5)
      expect(result.finish).to eq(8)
    end

    it 'returns nil when any pair is disjoint' do
      result = described_class.intersection([
                                              described_class.new(1, 5),
                                              described_class.new(10, 20)
                                            ])
      expect(result).to be_nil
    end
  end

  describe '.span' do
    it 'returns nil for empty input' do
      expect(described_class.span([])).to be_nil
    end

    it 'returns an equal interval for a single-element input' do
      i = described_class.new(1, 5)
      result = described_class.span([i])
      expect(result.start).to eq(1)
      expect(result.finish).to eq(5)
    end

    it 'returns the smallest interval covering all inputs' do
      intervals = [
        described_class.new(3, 7),
        described_class.new(1, 4),
        described_class.new(8, 10)
      ]
      result = described_class.span(intervals)
      expect(result.start).to eq(1)
      expect(result.finish).to eq(10)
    end

    it 'spans even across disjoint intervals (covering the gap)' do
      intervals = [described_class.new(1, 2), described_class.new(8, 9)]
      result = described_class.span(intervals)
      expect(result.start).to eq(1)
      expect(result.finish).to eq(9)
    end

    it 'returns a closed interval' do
      result = described_class.span([described_class.new(0, 1, type: :open)])
      expect(result.type).to eq(:closed)
    end
  end

  describe '#type' do
    it 'defaults to :closed' do
      expect(described_class.new(1, 5).type).to eq(:closed)
    end

    it 'accepts :open' do
      expect(described_class.new(1, 5, type: :open).type).to eq(:open)
    end

    it 'accepts :left_open' do
      expect(described_class.new(1, 5, type: :left_open).type).to eq(:left_open)
    end

    it 'accepts :right_open' do
      expect(described_class.new(1, 5, type: :right_open).type).to eq(:right_open)
    end

    it 'raises for invalid type' do
      expect { described_class.new(1, 5, type: :invalid) }.to raise_error(Philiprehberger::Interval::Error)
    end
  end

  describe '#include? with interval types' do
    it 'closed interval includes both endpoints' do
      interval = described_class.new(1, 5, type: :closed)
      expect(interval.include?(1)).to be true
      expect(interval.include?(5)).to be true
      expect(interval.include?(3)).to be true
    end

    it 'open interval excludes both endpoints' do
      interval = described_class.new(1, 5, type: :open)
      expect(interval.include?(1)).to be false
      expect(interval.include?(5)).to be false
      expect(interval.include?(3)).to be true
    end

    it 'left_open interval excludes left, includes right' do
      interval = described_class.new(1, 5, type: :left_open)
      expect(interval.include?(1)).to be false
      expect(interval.include?(5)).to be true
      expect(interval.include?(3)).to be true
    end

    it 'right_open interval includes left, excludes right' do
      interval = described_class.new(1, 5, type: :right_open)
      expect(interval.include?(1)).to be true
      expect(interval.include?(5)).to be false
      expect(interval.include?(3)).to be true
    end

    it 'returns false for points outside all interval types' do
      %i[closed open left_open right_open].each do |type|
        interval = described_class.new(1, 5, type: type)
        expect(interval.include?(0)).to be false
        expect(interval.include?(6)).to be false
      end
    end
  end

  describe '#overlaps? with interval types' do
    it 'closed intervals touching at a point overlap' do
      a = described_class.new(1, 5, type: :closed)
      b = described_class.new(5, 10, type: :closed)
      expect(a.overlaps?(b)).to be true
    end

    it 'right_open and closed intervals touching at a point do not overlap' do
      a = described_class.new(1, 5, type: :right_open)
      b = described_class.new(5, 10, type: :closed)
      expect(a.overlaps?(b)).to be false
    end

    it 'closed and left_open intervals touching at a point do not overlap' do
      a = described_class.new(1, 5, type: :closed)
      b = described_class.new(5, 10, type: :left_open)
      expect(a.overlaps?(b)).to be false
    end

    it 'open intervals touching at a point do not overlap' do
      a = described_class.new(1, 5, type: :open)
      b = described_class.new(5, 10, type: :open)
      expect(a.overlaps?(b)).to be false
    end

    it 'overlapping open intervals return true' do
      a = described_class.new(1, 6, type: :open)
      b = described_class.new(3, 10, type: :open)
      expect(a.overlaps?(b)).to be true
    end

    it 'zero-width open interval does not overlap anything' do
      a = described_class.new(3, 3, type: :open)
      b = described_class.new(1, 5, type: :closed)
      expect(a.overlaps?(b)).to be false
    end
  end

  describe '#to_s with interval types' do
    it 'formats closed as [a, b]' do
      expect(described_class.new(1, 5, type: :closed).to_s).to eq('[1, 5]')
    end

    it 'formats open as (a, b)' do
      expect(described_class.new(1, 5, type: :open).to_s).to eq('(1, 5)')
    end

    it 'formats left_open as (a, b]' do
      expect(described_class.new(1, 5, type: :left_open).to_s).to eq('(1, 5]')
    end

    it 'formats right_open as [a, b)' do
      expect(described_class.new(1, 5, type: :right_open).to_s).to eq('[1, 5)')
    end
  end

  describe '#shift' do
    it 'shifts interval by positive delta' do
      interval = described_class.new(1, 5).shift(3)
      expect(interval.start).to eq(4)
      expect(interval.finish).to eq(8)
    end

    it 'shifts interval by negative delta' do
      interval = described_class.new(5, 10).shift(-2)
      expect(interval.start).to eq(3)
      expect(interval.finish).to eq(8)
    end

    it 'preserves interval type' do
      interval = described_class.new(1, 5, type: :open).shift(3)
      expect(interval.type).to eq(:open)
      expect(interval.to_s).to eq('(4, 8)')
    end

    it 'handles zero shift' do
      interval = described_class.new(1, 5)
      shifted = interval.shift(0)
      expect(shifted.start).to eq(1)
      expect(shifted.finish).to eq(5)
    end
  end

  describe '#scale' do
    it 'scales from center by default' do
      interval = described_class.new(0.0, 10.0).scale(2)
      expect(interval.start).to eq(-5.0)
      expect(interval.finish).to eq(15.0)
    end

    it 'scales from left anchor' do
      interval = described_class.new(0.0, 10.0).scale(2, anchor: :left)
      expect(interval.start).to eq(0.0)
      expect(interval.finish).to eq(20.0)
    end

    it 'scales from right anchor' do
      interval = described_class.new(0.0, 10.0).scale(2, anchor: :right)
      expect(interval.start).to eq(-10.0)
      expect(interval.finish).to eq(10.0)
    end

    it 'scales down' do
      interval = described_class.new(0.0, 10.0).scale(0.5, anchor: :left)
      expect(interval.start).to eq(0.0)
      expect(interval.finish).to eq(5.0)
    end

    it 'preserves interval type' do
      interval = described_class.new(0.0, 10.0, type: :right_open).scale(2, anchor: :left)
      expect(interval.type).to eq(:right_open)
    end

    it 'raises for invalid anchor' do
      expect { described_class.new(0.0, 10.0).scale(2, anchor: :invalid) }.to raise_error(Philiprehberger::Interval::Error)
    end
  end

  describe '#split' do
    it 'splits into equal sub-intervals' do
      parts = described_class.new(0, 10).split(2)
      expect(parts.length).to eq(2)
      expect(parts[0].start).to eq(0.0)
      expect(parts[0].finish).to eq(5.0)
      expect(parts[1].start).to eq(5.0)
      expect(parts[1].finish).to eq(10.0)
    end

    it 'splits into three parts' do
      parts = described_class.new(0, 9).split(3)
      expect(parts.length).to eq(3)
      expect(parts[0].start).to eq(0.0)
      expect(parts[0].finish).to eq(3.0)
      expect(parts[2].start).to eq(6.0)
      expect(parts[2].finish).to eq(9.0)
    end

    it 'split of 1 returns equivalent interval' do
      parts = described_class.new(1, 5).split(1)
      expect(parts.length).to eq(1)
      expect(parts[0].start).to eq(1.0)
      expect(parts[0].finish).to eq(5.0)
    end

    it 'preserves interval type' do
      parts = described_class.new(0, 10, type: :left_open).split(2)
      expect(parts[0].type).to eq(:left_open)
      expect(parts[1].type).to eq(:left_open)
    end

    it 'raises for non-positive n' do
      expect { described_class.new(0, 10).split(0) }.to raise_error(Philiprehberger::Interval::Error)
    end
  end

  describe '#clamp' do
    it 'clamps value below interval to start' do
      expect(described_class.new(1, 5).clamp(0)).to eq(1)
    end

    it 'clamps value above interval to finish' do
      expect(described_class.new(1, 5).clamp(10)).to eq(5)
    end

    it 'returns value inside interval unchanged' do
      expect(described_class.new(1, 5).clamp(3)).to eq(3)
    end

    it 'returns start for value at start' do
      expect(described_class.new(1, 5).clamp(1)).to eq(1)
    end

    it 'returns finish for value at finish' do
      expect(described_class.new(1, 5).clamp(5)).to eq(5)
    end
  end

  describe 'edge cases' do
    it 'zero-width closed interval includes its point' do
      interval = described_class.new(3, 3, type: :closed)
      expect(interval.include?(3)).to be true
    end

    it 'zero-width open interval excludes its point' do
      interval = described_class.new(3, 3, type: :open)
      expect(interval.include?(3)).to be false
    end

    it 'shift with negative delta' do
      interval = described_class.new(10, 20, type: :left_open).shift(-15)
      expect(interval.start).to eq(-5)
      expect(interval.finish).to eq(5)
      expect(interval.type).to eq(:left_open)
    end

    it 'equality considers type' do
      a = described_class.new(1, 5, type: :closed)
      b = described_class.new(1, 5, type: :open)
      expect(a).not_to eq(b)
    end
  end

  describe 'with Time values' do
    it 'works with Time objects' do
      t1 = Time.new(2026, 1, 1)
      t2 = Time.new(2026, 6, 1)
      t3 = Time.new(2026, 3, 1)
      interval = described_class.new(t1, t2)
      expect(interval.include?(t3)).to be true
    end
  end

  describe 'with Float values' do
    it 'works with floating point numbers' do
      interval = described_class.new(1.5, 3.5)
      expect(interval.include?(2.0)).to be true
      expect(interval.size).to eq(2.0)
    end
  end

  describe '#sample' do
    describe 'without argument' do
      it 'returns a Float for a closed interval' do
        interval = described_class.new(1.0, 5.0, type: :closed)
        result = interval.sample
        expect(result).to be_a(Float)
        expect(result).to be >= 1.0
        expect(result).to be <= 5.0
      end

      it 'returns a Float strictly inside an open interval' do
        interval = described_class.new(1.0, 5.0, type: :open)
        100.times do
          result = interval.sample
          expect(result).to be > 1.0
          expect(result).to be < 5.0
        end
      end

      it 'returns a Float within a left_open (a, b] interval' do
        interval = described_class.new(1.0, 5.0, type: :left_open)
        100.times do
          result = interval.sample
          expect(result).to be > 1.0
          expect(result).to be <= 5.0
        end
      end

      it 'returns a Float within a right_open [a, b) interval' do
        interval = described_class.new(1.0, 5.0, type: :right_open)
        100.times do
          result = interval.sample
          expect(result).to be >= 1.0
          expect(result).to be < 5.0
        end
      end

      it 'returns start as Float for a point interval' do
        interval = described_class.new(3.0, 3.0, type: :closed)
        expect(interval.sample).to eq(3.0)
      end
    end

    describe 'with integer argument' do
      it 'returns an array of Floats for a closed interval' do
        interval = described_class.new(0.0, 10.0)
        results = interval.sample(5)
        expect(results).to be_an(Array)
        expect(results.length).to eq(5)
        results.each do |v|
          expect(v).to be_a(Float)
          expect(v).to be >= 0.0
          expect(v).to be <= 10.0
        end
      end

      it 'returns an empty array when n is 0' do
        interval = described_class.new(0.0, 10.0)
        expect(interval.sample(0)).to eq([])
      end

      it 'returns an array of n Floats within an open interval' do
        interval = described_class.new(2.0, 8.0, type: :open)
        results = interval.sample(10)
        expect(results.length).to eq(10)
        results.each do |v|
          expect(v).to be > 2.0
          expect(v).to be < 8.0
        end
      end
    end

    it 'raises an error for an empty interval' do
      interval = described_class.new(3.0, 3.0, type: :open)
      expect { interval.sample }.to raise_error(Philiprehberger::Interval::Error)
    end
  end
end
