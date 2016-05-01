#!/usr/bin/env ruby
require './cryptlib.rb'

block_size = 16
string = Base64.decode64(
  'L77na/nrFsKvynd6HzOoG7GHTLXsTVu9qvY/2syLXzhPweyyMTJULu/6/kXX0KSvoOLSFQ=='
)

nonce = [0].pack('Q')
key = 'YELLOW SUBMARINE'
puts decrypt_ctr_aes_128(string, key, nonce, block_size)
