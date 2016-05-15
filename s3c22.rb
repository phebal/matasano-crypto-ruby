#!/usr/bin/env ruby
require './cryptlib.rb'
require './s3c21.rb'


base_seed = Time.now.to_i + Random.new.rand(1000)
random_num = MT19937.new(base_seed).extract_number

current_time = base_seed + Random.new.rand(1000)

(0..2000).each {|i|
  if random_num == MT19937.new(current_time - i).extract_number
    puts "Base seed: #{current_time - i}"
    raise unless current_time - i == base_seed
  end
}
