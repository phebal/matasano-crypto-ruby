#!/usr/bin/env ruby
require 'pry'
require 'openssl'
require 'base64'
require './cryptlib.rb'

def decrypt_ecb(msg, key)
  cipher = OpenSSL::Cipher.new('AES-128-ECB')
  cipher.decrypt

  cipher.key = key
  tempkey = Base64.decode64(msg)
  crypt = cipher.update(tempkey)
  cipher.padding = 0
  crypt << cipher.final
  crypt
end

def decrypt_cbc_lib(msg, key, iv)
  cipher = OpenSSL::Cipher.new('AES-128-CBC')
  cipher.decrypt

  cipher.key = key
  cipher.iv = iv
  tempkey = Base64.decode64(msg)
  crypt = cipher.update(tempkey)
  cipher.padding = 0
  crypt << cipher.final
  crypt
end

def encrypt_ecb(msg, key)
  cipher = OpenSSL::Cipher.new('AES-128-ECB')
  cipher.encrypt

  cipher.key = key
  crypt = cipher.update(msg)
  crypt << cipher.final
  Base64.encode64(crypt)
end

def xor_by_index(msg1, msg2, index, step, so_far="")
  return so_far if msg1[index].nil?
  so_far << hex_to_string(
    xor_hex(
      str2hex(msg1[index..index+step-1]),
      str2hex(msg2[index..index+step-1])
    )
  )
  xor_by_index(msg1, msg2, index + step, step, so_far)
end

def decrypt_cbc(msg, key, iv)
  pass1_ecb = decrypt_ecb(msg, key)
  iv_msg = iv + Base64.decode64(msg)
  xor_by_index(pass1_ecb, iv_msg, 0, 16)
end

pass_phrase = 'YELLOW SUBMARINE'
msg = File.open('s2c10.txt').map {|o| o.strip }.join
iv = "\x00" * 16

#puts decrypt_cbc(msg, pass_phrase, iv)
puts decrypt_cbc_lib(msg, pass_phrase, iv)

