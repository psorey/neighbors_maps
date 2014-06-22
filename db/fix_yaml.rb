#!/usr/bin/env ruby

count = 0

File.open("half_blocks.yaml","r") do |f|  
  while line = f.gets  
    if line =~ /attributes:/
      puts "half_block_#{count}:"
      count += 1
    else
      puts line
    end   
  end  
end  