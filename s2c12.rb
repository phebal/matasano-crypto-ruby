#!/usr/bin/env ruby
require 'pry'
require 'openssl'
require 'base64'
require './cryptlib.rb'

key = random_bytes(16)
target = Base64.decode64('Um9sbGluJyBpbiBteSA1LjAKV2l0aCBteSByYWctdG9wIGRvd24gc28gbXkgaGFpciBjYW4gYmxvdwpUaGUgZ2lybGllcyBvbiBzdGFuZGJ5IHdhdmluZyBqdXN0IHRvIHNheSBoaQpEaWQgeW91IHN0b3A/IE5vLCBJIGp1c3QgZHJvdmUgYnkK')


def encryption_oracle(msg, key, padding)
  padded_msg = padding + msg
  encrypt_ecb(padded_msg, key)
end

def find_oracle_blocks_by_hamming(msg, key)
  (4..32).map do |size|
    padding = 'A' * (size * 3)
    canditate = encryption_oracle(msg, key, padding)
    score = hamming_distance_for_chunks(canditate, size)
    [score, size]
  end.sort_by {|o| o[0] }
end

def find_oracle_blocks_by_repeats(msg, key)
  (4..32).map do |size|
    padding = 'A' * size * 2
    canditate = encryption_oracle(msg, key, padding)
    score = find_repeating_blocks(canditate, size)
    [score, size]
  end.sort_by {|o| o[0] }
end

def guess_block_size(msg, key)
  block_guesses = find_oracle_blocks_by_hamming(msg, key)
  block_guesses[0..1].sort_by {|o| o[1] }.first[1]
end

def check_if_ecb(target, key, size)
  padding = 'A' * size * 2
  padded_crypt = encryption_oracle(target, key, padding)
  raise "Not ECB" if find_repeating_blocks(padded_crypt, size) == 0
end

def oracle_dictionary(key)
  @dictionary ||= 128.times.inject({}) do |h, num|
    msg = 'A' * (key.length - 1) + num.chr
    crypt = encrypt_ecb(msg, key)[0..key.length - 1]
    h[crypt] = num.chr
    h
  end
end

def break_cypher(msg, key, size)
  chunk = msg.length.times.map do |i|
    padded_msg = 'A' * (size - 1) + msg[i]
    crypt = encrypt_ecb(padded_msg, key)[0..size - 1]
    oracle_dictionary(key)[crypt]
  end.join
end

block_size = guess_block_size(target, key)
puts "Selected block size of: #{block_size}"
check_if_ecb(target, key, block_size)
puts break_cypher(target, key, block_size)
