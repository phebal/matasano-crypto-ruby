#!/usr/bin/env ruby
require './cryptlib.rb'

@block_size = 16
@nonce = [0].pack('Q')
@key = random_bytes(16)

@strings = File.readlines('./s3c20.txt').map do |line|
  line = Base64.decode64(line.strip)[0..@block_size-1]
  encrypt_ctr_aes_128(line, @key, @nonce, @block_size)
end


def column(index)
  @strings.map {|o| o[index] }.join
end

def ascii_frequency(str)
  eng_freq = ' etaoinshrdlcumwfgypbvkjxqz'.reverse
  str.chars.map {|ch| eng_freq.index(ch).to_i }.inject(:+)
end

def ascii_first_letter_frequency(str)
  eng_freq = 'TAISOCMFPW'.reverse
  str.chars.map {|ch| eng_freq.index(ch).to_i }.inject(:+)
end

def columns_to_string(columns)
  (0..columns.first.length-1).map { |idx|
    columns.map { |col| col[idx] }.join
  }.join("\n")
end

def frequency_based_search
  freq_method = 'ascii_first_letter_frequency'
  (0..@block_size-1).map do |idx|
    col = column(idx)
    plain = (0..255).map { |o|
      str = xor_string(col, o.chr * col.length)
      rank = send(freq_method, str)
      #key_char = xor_string(str[0], col[0])
      #[rank, key_char]
      [rank, str]
    }.sort_by(&:first).last
    freq_method = 'ascii_frequency'
    plain
  end
end

search_results = frequency_based_search
puts columns_to_string(search_results.map(&:last))
