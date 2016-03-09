#!/usr/bin/env ruby
text = "Burning 'em, if you ain't quick and nimble\nI go crazy when I hear a cymbal"
expected = '0b3637272a2b2e63622c2e69692a23693a2a3c6324202d623d63343c2a26226324272765272a282b2f20430a652e2c652a3124333a653e2b2027630c692b20283165286326302e27282f'

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

def repeating_key_xor(str, key)
  full_key = (key * (str.length/3 + 1))[0..str.length - 1]
  xor_hex(str_2_hex(str), str_2_hex(full_key))
end

final_hex = repeating_key_xor(text, 'ICE')
raise if final_hex != expected
puts "All good, final hex: #{final_hex}"
