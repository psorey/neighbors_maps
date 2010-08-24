require 'active_record/fixtures'

class LoadFixtures < ActiveRecord::Migration
  def self.up
  	down
  	directory = File.join(File.dirname(__FILE__), 'dev_data' )
  	Fixtures.create_fixtures(directory, "neighbors" )
  	Fixtures.create_fixtures(directory, "half_blocks" )

  	
  end

  def self.down
  	Neighbor.delete_all
  	HalfBlock.delete_all
  end
end