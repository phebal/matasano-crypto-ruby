#!/usr/bin/env ruby
require 'openssl'
require 'base64'

cipher = OpenSSL::Cipher.new('AES-128-ECB')
cipher.decrypt
pass_phrase = 'YELLOW SUBMARINE'

cipher.key = pass_phrase
msg = File.open('s1c7.txt').read
tempkey = Base64.decode64(msg)
crypt = cipher.update(tempkey)
crypt << cipher.final

puts crypt
