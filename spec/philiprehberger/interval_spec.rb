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

  describe '#size' do
    it 'returns the length of the interval' do
      expect(described_class.new(1, 5).size).to eq(4)
    end

    it 'returns zero for point interval' do
      expect(described_class.new(3, 3).size).to eq(0)
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
end
