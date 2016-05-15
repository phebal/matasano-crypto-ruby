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
end
