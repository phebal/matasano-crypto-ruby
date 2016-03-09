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
  repeats
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

def cypher_detection(msg)
  repeats = find_repeating_blocks(msg, 16)
  if repeats.empty?
    'CBC'
  else
    'ECB'
  end
end
