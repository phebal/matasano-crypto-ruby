#!/usr/bin/env ruby
require './cryptlib.rb'

def aes_key
  @key ||= random_bytes(16)
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

def parse_url_params(params)
  params.split('&')
        .map {|p|
    p.split('=')
  }.inject({}){|h, (key, val)|
    h[key] = val and h
  }
end

def profile_for(email)
  email.gsub('=', '').gsub!('&', '')
  profile = "email=#{email}&uid=10&role=user"
  encrypt_ecb(profile, aes_key)
end

def process_encrypted_profile(profile)
  encoded_profile = decrypt_ecb(profile, aes_key)
  puts encoded_profile
  parse_url_params(encoded_profile)
end

def insert_admin_role
  # Baseline
  # email=haX0r@asd.net&uid=10&role=user
  # Spoofed
  # email=haX0r@asd.admin[padding]net&uid=10&role=user
  baseline = profile_for('haX0r@asd.net')
  tailored = profile_for("haX0r@asd." + pad('admin', 16))
  spoofed = baseline[0..31] + tailored[16..31]
  process_encrypted_profile(spoofed)
end

block_size = 16
puts insert_admin_role
