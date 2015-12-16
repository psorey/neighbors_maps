# require 'spatial_adapter/postgresql'

class Neighbor < ActiveRecord::Base

  belongs_to :users  # foreign_key = neighbor_id

  serialize :why_walk, Array
  serialize :dont_walk, Array
  serialize :improvements, Array
  serialize :volunteer, Array

  def get_address_string
    address_string = self.address.gsub(/\s/, '+')
    address_string += ',Seattle,WA' 
    address_string.chomp!
    return address_string
  end

  def get_half_block_id
    sql = "SELECT DISTINCT b.half_block_id FROM half_blocks AS b, neighbors AS n  WHERE n.id = '#{self.id}' AND ST_Contains(b.the_geom,n.location)"
    half_block = HalfBlock.find_by_sql(sql)[0]
    if half_block
      half_block_id = half_block.half_block_id
      return half_block_id
    else
      return 'outside project area'
    end

  end
end


