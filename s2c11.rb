#!/usr/bin/env ruby
require 'pry'
require 'openssl'
require 'base64'
require './cryptlib.rb'

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

def encryption_oracle(msg)
  padded_msg = random_bytes(5..10) + msg + random_bytes(5..10)
  key = random_bytes(16)
  if Random.new.rand(2) == 0
    type = 'CBC'
    crypt = encrypt_cbc_lib(padded_msg, key, random_bytes(16))
  else
    type = 'ECB'
    crypt = encrypt_ecb(padded_msg, key)
  end
  [type, crypt]
end

def cypher_detection(msg)
  repeats = find_repeating_blocks(msg, 16)
  if repeats.empty?
    'CBC'
  else
    'ECB'
  end
end

plain = File.open('s2c11.txt').read
cipher,msg = encryption_oracle(plain)

detected = cypher_detection(msg)
raise unless cipher == detected
