require 'spatial_adapter/postgresql'

class Neighbor < ActiveRecord::Base
  
=begin
	serialize :user_preferences, Array
	serialize :interests, Array
	serialize :energy_priorities, Array
	
	has_many :assets, :as => :attachable, :dependent => :destroy
	
  Max_Attachments = 20
  Max_Attachment_Size = 1.megabyte

  def validate_attachments
    errors.add_to_base("Too many attachments - maximum is #{Max_Attachments}") if assets.length > Max_Attachments
    assets.each {|a| errors.add_to_base("#{a.name} is over #{Max_Attachment_Size/1.megabyte}MB") if a.file_size > Max_Attachment_Size}

  end
=end

  serialize :why_walk, Array
  serialize :dont_walk, Array
  serialize :improvements, Array
  serialize :volunteer, Array
  
	def get_address_string	
		address_string = self.address.gsub(/\s/, '+')
		address_string += ',Seattle,WA' 
		address_string.chomp!
		logger.debug"address string = ==== === == == ===== ==== #{address_string}"
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
=begin
 SELECT
  m.name,
  sum(ST_Length(r.the_geom))/1000 as roads_km
FROM
  bc_roads AS r,
  bc_municipality AS m
WHERE
  ST_Contains(m.the_geom,r.the_geom)
GROUP BY m.name
ORDER BY roads_km; 
end
=end