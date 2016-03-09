#!/usr/bin/env ruby
require 'pry'
require 'base64'

def hex_to_binary(hex)
  [hex].pack('H*').unpack('B*').first
end

def hex_to_string(hex)
  [hex].pack('H*')
end

def str_2_hex(str)
  str.unpack('H*').first
end

def xor_hex(h1, h2)
  raise "Lengths do not match: #{h1.length} #{h2.length}" if h1.length != h2.length
  (0..h1.length - 1).map do |i|
    result = h1[i].to_i(16) ^ h2[i].to_i(16)
    raise "Bad xor result: #{result}" if result > 15
    result.to_s(16)
  end.join
end

def score_frequency(str)
  eng_freq = 'etaoinshrdlcumwfgypbvkjxqz'.reverse
  str.chars.map {|ch|
    eng_freq.index(ch).to_i
  }.inject(:+)
end

def hamming_distance(str1, str2)
  xor_result = xor_hex(str_2_hex(str1), str_2_hex(str2))
  hex_to_binary(xor_result).count('1')
end

def hamming_distance_for_chunks(encrypted_xor, size)
  chunks = encrypted_xor.unpack("a#{size}" * (encrypted_xor.length/size))
  scores = []
  chunks.each_with_index do |chunk, idx|
    score = []
    chunks.each_with_index {|chunk2, idx2|
      next if idx == idx2
      score << hamming_distance(chunk, chunk2) / size.to_f
    }
    scores << score.inject(:+) / (encrypted_xor.length / size - 1).to_f
  end
  scores.inject(:+) / (encrypted_xor.length / size)
end

def find_repeating_blocks(str, size)
  chunks = str.unpack("a#{size}" * (str.length/size))
  repeats = []
  chunks.each_with_index do |chunk1, idx1|
    count = 1
    chunks.each_with_index do |chunk2, idx2|
      next if idx1 == idx2
      next if chunk1 != chunk2
      count += 1
    end
    next if repeats.include?(chunk1) or count == 1
    repeats << chunk1
    puts "Block #{chunk1}, repeats #{count} times" if count > 0
  end
  puts "String #{str} has repeats." unless repeats.empty?
end

File.open('s1c8.txt').map do |line|
  find_repeating_blocks(line.strip, 16)
end
