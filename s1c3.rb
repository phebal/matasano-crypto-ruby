#!/usr/bin/env ruby
str = '1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736'

def score_frequency(str)
  eng_freq = 'etaoinshrdlcumwfgypbvkjxqz'.reverse
  str.chars.map {|ch|
    eng_freq.index(ch).to_i
  }.inject(:+)
end

def hex_to_string(hex)
  [hex].pack('H*')
end

def xor_hex(h1, h2)
  raise "Lengths do not match: #{h1.length} #{h2.length}" if h1.length != h2.length
  (0..h1.length - 1).map do |i|
    result = h1[i].to_i(16) ^ h2[i].to_i(16)
    raise "Bad xor result: #{result}" if result > 15
    result.to_s(16)
  end.join
end

arr = (0..127).map do |int|
  char = int.chr.unpack('H*') 
  ch_str = (char * (str.length / 2)).join
  hex_res = xor_hex(str, ch_str)
  #puts hex_to_string(hex_res).gsub(/[\x00-\x1F\x7F]/, '')
  score = score_frequency(hex_to_string(hex_res))
  [score, char, hex_to_string(hex_res)]
end

winner = arr.sort_by {|a| a[0]}.last
puts "Winner: '#{winner[2]}' XOR'd with character '#{winner[1].pack('H*')}'"
