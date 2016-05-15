#!/usr/bin/env ruby
require './cryptlib.rb'

class MT19937
  def initialize(seed)
    @index = 624
    @mt = [0] * 624
    @mt[0] = seed
    (1..623).each do |idx|
      # Shift previous int by 30 bits to the right
      # and xor with the previous bit
      result = (@mt[idx - 1] >> 30) ^ @mt[idx - 1]
      result = result * 0x6c078965 + idx
      # Lowest 32 bits of the result
      @mt[idx] = result & 0xFFFFFFFF
    end
  end

  def reinitialize_from_array(array)
    @mt = array.dup
    @index = 624
  end

  def extract_number
    twist if @index >= 624

    result = @mt[@index]
    result = result ^ (result >> 11)
    result = result ^ ((result << 7) & 0x9D2C5680)
    result = result ^ ((result << 15) & 0xEFC60000)
    result = result ^ (result >> 18)

    @index = (@index + 1)

    result & 0xFFFFFFFF
  end

  def self.unextract_mt19937_number(number)
    # Frist two operations are simple since we have more then have original bits
    result = number ^ (number >> 18)
    result = result ^ ((result << 15) & 0xEFC60000)
    result = revert_7_bit_shift(result)
    result = revert_11_bit_shift(result)
  end

  private

  def twist
    (0..623).each do |idx|
      # Most significant bit of current integer
      msb_value = @mt[idx] & 0x80000000
      next_integer = @mt[(idx + 1) % 624]
      # 31 last bits of the next integer
      lsb_value = next_integer & 0x7FFFFFFF
      # Add and apply a 32-bit mask
      result = (msb_value + lsb_value) & 0xFFFFFFFF

      @mt[idx] = @mt[(idx + 397) % 624] ^ (result >> 1)

      if result % 2 != 0
        @mt[idx] = @mt[idx] ^ 0x9908B0DF
      end
    end
    @index = 0
  end

  def self.revert_7_bit_shift(number)
    # Bits 25-32 are originals, we use them to recover the previous
    # bits 7 bits at the time. We have to recover 24 bits
    # so we have to shift 4 times
    recovered_bits = number
    4.times do
      recovered_shifted = recovered_bits << 7
      intermediate = 0x9D2C5680 & recovered_shifted
      recovered_bits = intermediate ^ number
    end
    recovered_bits
  end

  def self.revert_11_bit_shift(number)
    # Bits 1-21 are originals, we use them to recover the next
    # bits, 11 bits at the time. We have to recover 20 bits
    # so we have to shift 2 times
    recovered_bits = number
    2.times do
      recovered_shifted = recovered_bits >> 11
      recovered_bits = recovered_shifted ^ number
    end
    recovered_bits
  end
end
