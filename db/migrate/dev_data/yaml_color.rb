#!/usr/bin/env ruby

require 'yaml'

# half_block_id low and high:

LOW_NUMBER = 101
HIGH_NUMBER = 535

# 535 - 101 = 434

#  scalar = 64000 / 434


#readme = YAML::load( File.open( 'README' ) )
#File.open("my_" + filename, 'w') {|f| f.write(maptext) }
#File.open("test.map", 'w') {|f| f.write(maptext) }

def convert_hex_to_rgb_string(hex_string)
  r = hex_string[0..1]
  g = hex_string[2..3]
  b = hex_string[4..5]
  
  "#{r.hex} #{g.hex} #{b.hex}"  
end


def convert_id_to_color(id)
  puts "id"
  puts id
  number = id.gsub( /\A"/m, "" ).gsub( /"\Z/m, "" ).to_i # remove quotes from string

  number -= LOW_NUMBER
  scalar = 'ffffff'.hex.to_f / (HIGH_NUMBER.to_f - LOW_NUMBER)
  color = number * scalar
  
  puts 'scalar'
  puts scalar
  puts 'number'
  puts number
  puts 'color'
  puts color
  
  if color < '777777'.hex
    color += '777777'.hex
  end

  hex_color = color.to_i.to_s(16)
  puts 'hex color'
  puts hex_color
  puts ''
  convert_hex_to_rgb_string(hex_color)
end


yaml_text = File.read("half_blocks_before_color.yml")

output_text =''

yaml_text.each do |line|
  output_text << line
  if line =~ /half_block_id:/
    match_data = /"[0-9].*"/.match(line)

    hex_color = convert_id_to_color(match_data[0])
    output_text << "  fill_color: #{hex_color}\n"
  end  
end

aFile = File.new("half_blocks_after_RGB.yml", "w")
aFile.write(output_text)
aFile.close


