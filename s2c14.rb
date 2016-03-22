#!/usr/bin/env ruby
require 'pry'
require 'openssl'
require 'base64'
require './cryptlib.rb'

key = random_bytes(16)
target = Base64.decode64('Um9sbGluJyBpbiBteSA1LjAKV2l0aCBteSByYWctdG9wIGRvd24gc28gbXkgaGFpciBjYW4gYmxvdwpUaGUgZ2lybGllcyBvbiBzdGFuZGJ5IHdhdmluZyBqdXN0IHRvIHNheSBoaQpEaWQgeW91IHN0b3A/IE5vLCBJIGp1c3QgZHJvdmUgYnkK')
@prefix = random_bytes(1..128)
#@prefix = random_bytes(99)

def encryption_oracle(msg, key, padding)
  padded_msg = @prefix + padding + msg
  encrypt_ecb(padded_msg, key)
end

def oracle_dictionary(key, padding, block_size)
  raise "Bad padding #{padding}" unless padding.length == (block_size - 1)
  128.times.inject({}) do |h, num|
    msg = padding + num.chr
    crypt = encrypt_ecb(msg, key)[0..block_size - 1]
    h[crypt] = num.chr
    h
  end
end

def find_prefix_length(msg, key, block_size)
  pad_size, repeats_idx = create_repeating_blocks(msg, key, block_size)
  pre_blocks = repeats_idx.first * block_size
  pre_reminder = block_size - (pad_size % block_size)
  length = pre_blocks + pre_reminder
  raise "Bad prefix size guess #{length} != #{@prefix.length}" if length != @prefix.length
  [length, (repeats_idx.first + 1) * block_size]
end

def create_repeating_blocks(msg, key, block_size)
  scrambled = encryption_oracle(msg, key, '')
  blocks = first_consecutsve_repeating_blocks(scrambled, block_size)
  raise "Some other blocks repeat" unless blocks.empty?
  (32..47).each_with_index do |size|
    custom = 'A' * size
    scrambled = encryption_oracle(msg, key, custom)
    blocks = first_consecutsve_repeating_blocks(scrambled, block_size)
    return [size, blocks] if !blocks.empty?
  end

  if blocks.empty?
    raise "Repeats not found for prefix #{@prefix.length}"
  end
end

def break_cypher(msg, key, block_size, prefix_size, pad_block_start)
  extra_pad_size = pad_block_start - prefix_size
  pad_size = extra_pad_size + (block_size - 1)
  decrypted = ""
  dict_pad = 'A' * 15
  msg_length = encryption_oracle(msg, key, '')[prefix_size..-1].length
  (msg_length/block_size.to_f).ceil.times do |block_nr|
    pad_text = 'A' * pad_size
    block_start = pad_block_start + (block_nr * block_size)
    block_end = block_start + block_size - 1

    (block_size - 1).downto(0) do |block_idx|
      crypt = encryption_oracle(msg, key, pad_text)
      chunk = crypt[block_start..block_end]
      plain_char = oracle_dictionary(key, dict_pad, block_size)[chunk]
      return decrypted if plain_char.nil?

      pad_text.chop!
      dict_pad.slice!(0)
      dict_pad << plain_char
      decrypted << plain_char
    end
  end
  decrypted
end

block_size = 16
prefix, pad_block_start = find_prefix_length(target, key, block_size)
plain = break_cypher(target, key, block_size, prefix, pad_block_start)
puts plain

