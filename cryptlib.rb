require 'pry'
require 'openssl'
require 'base64'

def hex2bin(hex)
  [hex].pack('H*').unpack('B*').first
end

def hex2string(hex)
  [hex].pack('H*')
end

def str2hex(str)
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

def xor_string(s1, s2)
  hex2string(xor_hex(str2hex(s1), str2hex(s2)))
end

def split_to_chunks(str, size)
  str.unpack("a#{size}" * (str.length/size))
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
    next if repeats.any? {|o| o[0] == chunk1 } || count == 1
    repeats << [chunk1, count]
  end
  repeats.inject(0) {|score, result| score + result[1].to_i }
end

def decrypt_ecb(msg, key)
  cipher = OpenSSL::Cipher.new('AES-128-ECB')
  cipher.decrypt

  cipher.key = key
  crypt = cipher.update(msg)
  crypt << cipher.final
  crypt
end

def decrypt_cbc_lib(msg, key, iv)
  cipher = OpenSSL::Cipher.new('AES-128-CBC')
  cipher.decrypt

  cipher.key = key
  cipher.iv = iv
  crypt = cipher.update(msg)
  cipher.padding = 0
  crypt << cipher.final
  crypt
end

def encrypt_cbc_lib(msg, key, iv)
  cipher = OpenSSL::Cipher.new('AES-128-CBC')
  cipher.encrypt

  cipher.key = key
  cipher.iv = iv
  crypt = cipher.update(msg)
  crypt << cipher.final
end

def encrypt_ecb(msg, key)
  cipher = OpenSSL::Cipher.new('AES-128-ECB')
  cipher.encrypt

  cipher.key = key
  crypt = cipher.update(msg)
  crypt << cipher.final
end

def random_bytes(size)
  if (size).is_a?(Range)
    size = Random.new.rand(size)
  end
  Random.new.bytes(size)
end

def is_ecb?(msg, size)
  repeats = find_repeating_blocks(msg, size)
  if repeats.empty?
    false
  else
    true
  end
end

def hamming_distance(str1, str2)
  xor_result = xor_hex(str2hex(str1), str2hex(str2))
  hex2bin(xor_result).count('1')
end

def hamming_distance_for_chunks(str, size)
  chunks = str.unpack("a#{size}" * (str.length/size))
  scores = []
  chunks.each_with_index do |chunk, idx|
    score = []
    chunks.each_with_index {|chunk2, idx2|
      next if idx == idx2
      score << hamming_distance(chunk, chunk2) / size.to_f
    }
    scores << score.inject(:+) / (str.length / size - 1).to_f
  end
  scores.inject(:+) / (str.length / size)
end