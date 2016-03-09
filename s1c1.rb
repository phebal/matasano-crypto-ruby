#!/usr/bin/env ruby
hex = '49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d'

def base64_to_ascii(int)
  case int
  when 62
    43
  when 63
    47
  when 0..25
    int + 65
  when 26..51
    (int % 26) + 97
  when 52..61
    (int % 52) + 48
  else
    raise 'Error'
  end
end

def hex_to_binary(hex)
  [hex].pack('H*').unpack('B*').first
end

def hex_to_base64(hex)
  binary = hex_to_binary(hex)
  binary.scan(/....../).map do |bin_str|
    bin_int = bin_str.to_i(2)
    base64_to_ascii(bin_int).chr
  end.join
end

puts hex_to_base64(hex)
