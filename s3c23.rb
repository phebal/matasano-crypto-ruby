#!/usr/bin/env ruby
require './cryptlib.rb'
require './s3c21.rb'

mt = MT19937.new(Time.now.to_i)
random_nums = (1..624).map { mt.extract_number }
# mt's @index is now at 624 and it'll twist

unextracted_arr = random_nums.map {|num| MT19937.unextract_mt19937_number(num) }
spoofed_mt = MT19937.new(Time.now.to_i)
spoofed_mt.reinitialize_from_array(unextracted_arr)

624.times do
  raise "Didn't work!" if mt.extract_number != spoofed_mt.extract_number
end

puts "It worked!"
