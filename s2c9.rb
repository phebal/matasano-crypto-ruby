#!/usr/bin/env ruby

def pad_to_size(block, size)
  return block if block.bytes.count == size
  missing_bytes = size - block.bytes.count
  missing_bytes.times do
    block << "\x04"
  end
  raise unless block.bytes.count == size
  block
end

padded = pad_to_size("YELLOW SUBMARINE", 20)
puts padded.inspect
