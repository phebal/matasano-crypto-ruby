#!/usr/bin/env ruby
hex1 = '1c0111001f010100061a024b53535009181c'
hex2 = '686974207468652062756c6c277320657965'

def hex_to_binary(hex)
  [hex].pack('H*').unpack('B*').first
end

def xor(h1, h2)
  (0..h1.length - 1).map do |i|
    result = h1[i].to_i(16) ^ h2[i].to_i(16)
    raise "Bad xor result: #{result}" if result > 15
    result.to_s(16)
  end.join
end

puts xor(hex1, hex2)
