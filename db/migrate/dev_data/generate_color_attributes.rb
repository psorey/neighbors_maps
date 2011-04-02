#!/usr/bin/env ruby

require 'yaml'

# half_block_id low and high:

LOW_NUMBER = 101
HIGH_NUMBER = 535

# 535 - 101 = 434

#  scalar = 64000 / 434

File.open("half_blocks_before_color.yaml","r") do |f|

#readme = YAML::load( File.open( 'README' ) )



class HalfBlock 
  attr_accessor :boundary_t, :half_block_id, :fill_color, :the_geom, :created_at, :modified_at, :id
end

def dump(file, object)
  File.open(file, 'a') do |out|
    YAML.dump(object.to_yaml, out)
  end
  object = nil
end

def convert_id_to_color(id)
  number = id.to_f
  number -= LOW_NUMBER
  scalar = 'ffffff'.hex.to_f / (HIGH_NUMBER.to_f - LOW_NUMBER)
  color = number * scalar
  if color < '777777'.hex
    color += '777777'.hex
  end

  hex_color = color.to_i.to_s(16)
  puts hex_color
  return hex_color
end

half_blocks = YAML::load( File.open( 'half_blocks_mod.yml' ) )
 
half_blocks.each do |half_block| 
  half_block.fill_color = convert_id_to_color(half_block.half_block_id)

  dump('colored_half_blocks.yml', half_block)
  
end



