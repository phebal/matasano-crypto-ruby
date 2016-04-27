#!/usr/bin/env ruby
require 'pry'
require 'openssl'
require 'base64'
require './cryptlib.rb'

@key = random_bytes(16)
@iv = random_bytes(16)
@block_size = 16

def encryption_oracle(msg)
  msg = msg.to_s.tr(';=', '')
  full_msg = "comment1=cooking%20MCs;userdata=#{msg};comment2=%20like%20a%20pound%20of%20bacon"
  full_msg = pad(full_msg, @block_size)
  encrypt_cbc_lib(full_msg, @key, @iv)
end

def is_admin?(msg)
  plain = decrypt_cbc_lib(msg, @key, @iv)
  plain_h = plain.split(';').inject({}) {|h, o|
    h[o.split('=').first] = o.split('=').last
    h
  }
  plain_h['admin'] == 'true'
end

def insert_admin
  #16-ch pad for the garbage block and 5-character pad for ;admin=true
  msg = encryption_oracle('0123456789ABCDEFaaaaa,admin~true')
  #comment1=cooking%20MCs;userdata=aaaaa,admin~true;comment2=%20like%20a%20pound%20of%20bacon
  # , in position 37 needs to become ;
  msg[37] = xor_string(xor_string(msg[37], ','), ';')
  # ~ on in position 43 needs to become =
  msg[43] = xor_string(xor_string(msg[43], '~'), '=')
  msg[33] = 'c'
  msg
end

puts is_admin?(insert_admin)
