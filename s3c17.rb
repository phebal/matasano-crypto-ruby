#!/usr/bin/env ruby
require 'pry'
require 'openssl'
require 'base64'
require './cryptlib.rb'

@key = random_bytes(16)
@iv = random_bytes(16)
@block_size = 16

@strings = %w(
  MDAwMDAwTm93IHRoYXQgdGhlIHBhcnR5IGlzIGp1bXBpbmc=
  MDAwMDAxV2l0aCB0aGUgYmFzcyBraWNrZWQgaW4gYW5kIHRoZSBWZWdhJ3MgYXJlIHB1bXBpbic=
  MDAwMDAyUXVpY2sgdG8gdGhlIHBvaW50LCB0byB0aGUgcG9pbnQsIG5vIGZha2luZw==
  MDAwMDAzQ29va2luZyBNQydzIGxpa2UgYSBwb3VuZCBvZiBiYWNvbg==
  MDAwMDA0QnVybmluZyAnZW0sIGlmIHlvdSBhaW4ndCBxdWljayBhbmQgbmltYmxl
  MDAwMDA1SSBnbyBjcmF6eSB3aGVuIEkgaGVhciBhIGN5bWJhbA==
  MDAwMDA2QW5kIGEgaGlnaCBoYXQgd2l0aCBhIHNvdXBlZCB1cCB0ZW1wbw==
  MDAwMDA3SSdtIG9uIGEgcm9sbCwgaXQncyB0aW1lIHRvIGdvIHNvbG8=
  MDAwMDA4b2xsaW4nIGluIG15IGZpdmUgcG9pbnQgb2g=
  MDAwMDA5aXRoIG15IHJhZy10b3AgZG93biBzbyBteSBoYWlyIGNhbiBibG93
)


def select_and_encrypt
  @full_msg = @strings[Random.new.rand(9)]
  encrypt_cbc_lib(@full_msg, @key, @iv)
end

def find_pad(block, pad_size, previous_pad)
  if !previous_pad.empty?
    previous_pad = previous_pad.chars.map {|o|
      xor_string(xor_string(o, (pad_size - 1).chr), pad_size.chr)
    }.join
  end

  block_position = @block_size - pad_size
  original_char = block[block_position]
  (0..255).each do |i|
    # Mostly the original character is is a false positive
    next if original_char == i.chr
    new_pad = i.chr + previous_pad
    begin
      block[block_position..@block_size-1] = new_pad
      decrypt_cbc_lib(block, @key, @iv)
      return new_pad
    rescue OpenSSL::Cipher::CipherError
    end
  end
  # The original character is not a false positive
  # when the padding oracle padding matches the original
  # padding. In which case the all character of the mask
  # will match the original characters.
  original_char + previous_pad
end

def break_chunk(block)
  pad = ''
  copy = block.dup
  (1..@block_size).map do |i|
    pad = find_pad(copy, i, pad)
    plain_ch = xor_string(xor_string(pad[0], block[@block_size-i]), i.chr)
  end.reverse.join
end

def padding_oracle(msg)
  chunks = [@iv]
  chunks += split_to_chunks(msg, @block_size)
  (0..chunks.size - 2).map do |i|
    break_chunk(chunks[i] + chunks[i+1])
  end.join
end

msg = select_and_encrypt
puts "Full:"
puts @full_msg
puts "Reversed:"
puts padding_oracle(msg)
