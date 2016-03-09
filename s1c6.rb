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

def single_character_xor_search(hex)
  (0..127).map do |int|
    char = int.chr.unpack('H*')
    ch_hex = (char * (hex.length / 2)).join
    hex_res = xor_hex(hex, ch_hex)
    score = score_frequency(hex_to_string(hex_res))
    [score, char.pack('H*'), hex_to_string(hex_res)]
  end.sort_by {|o| o[0] }
end

def hamming_distance(str1, str2)
  xor_result = xor_hex(str_2_hex(str1), str_2_hex(str2))
  hex_to_binary(xor_result).count('1')
end

def repeating_key_xor(str, key)
  full_key = (key * (str.length/3 + 1))[0..str.length - 1]
  xor_hex(str_2_hex(str), str_2_hex(full_key))
end

def find_key_sizes(encrypted_xor)
  (2..40).map do |size|
    chunks = encrypted_xor.unpack("a#{size}" * (encrypted_xor.length/size))
    ham_dst1 = hamming_distance(chunks[2], chunks[8]) / size.to_f
    ham_dst2 = hamming_distance(chunks[9], chunks[20]) / size.to_f
    ham_dst3 = hamming_distance(chunks[4], chunks[11]) / size.to_f
    ham_dst4 = hamming_distance(chunks[6], chunks[28]) / size.to_f
    ham_dst5 = hamming_distance(chunks[3], chunks[23]) / size.to_f
    ham_dst6 = hamming_distance(chunks[5], chunks[29]) / size.to_f
    ham_dst7 = hamming_distance(chunks[1], chunks[12]) / size.to_f
    [size, ((ham_dst1 + ham_dst2 + ham_dst3 + ham_dst4 + ham_dst5 + ham_dst6 + ham_dst7) / 7)]
    #[size, ham_dst1]
  end
end

def key_based_columns(encrypted_xor, size)
  chunks = encrypted_xor.unpack("a#{size}" * (encrypted_xor.length/size))
  chunks.inject([]) {|a, chunk|
    chunk.chars.each_with_index {|byte, idx|
      if a[idx].nil?
        a[idx] = [byte]
      else
        a[idx] << byte
      end
    }
    a
  }
end

def single_character_columns_search(columns)
  decr_cols = columns.map {|c|
    decr_str = single_character_xor_search(str_2_hex(c.join)).last
    [decr_str[1], decr_str[2]]
  }
  decr_arr = []
  (0..columns.first.size-1).each {|col_pos|
    (0..columns.size-1).each {|col_nr|
      decr_arr << decr_cols[col_nr][1][col_pos]
    }
  }
  [decr_arr.join, decr_cols.map(&:first).join]
end

encrypted_b64 = File.open('s1c6.txt').each.map(&:strip).join
encrypted_xor = Base64.decode64(encrypted_b64)

key_sizes = find_key_sizes(encrypted_xor).sort_by {|a| a[1] }
columns = key_based_columns(encrypted_xor, key_sizes.first[0])
decrypted_a = single_character_columns_search(columns)
puts "Text:\n#{decrypted_a[0]}\n\nKey: #{decrypted_a[1]}"
