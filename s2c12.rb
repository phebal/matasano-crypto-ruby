#!/usr/bin/env ruby
require 'pry'
require 'openssl'
require 'base64'
require './cryptlib.rb'

def encryption_oracle(msg, key, padding)
  padded_msg = padding + msg
  encrypt_ecb(padded_msg, key)
end

def find_oracle_blocks(msg, key)
  (1..32).each do |idx|
    find_repeating_blocks(msg, idx)
  end
end

key = random_bytes(16)
target = Base64.decode64('Um9sbGluJyBpbiBteSA1LjAKV2l0aCBteSByYWctdG9wIGRvd24gc28gbXkgaGFpciBjYW4gYmxvdwpUaGUgZ2lybGllcyBvbiBzdGFuZGJ5IHdhdmluZyBqdXN0IHRvIHNheSBoaQpEaWQgeW91IHN0b3A/IE5vLCBJIGp1c3QgZHJvdmUgYnkK')

cipher,msg = encryption_oracle(plain, key)

detected = cypher_detection(msg)
raise unless cipher == detected
