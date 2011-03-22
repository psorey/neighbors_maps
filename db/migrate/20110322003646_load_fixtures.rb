require 'active_record/fixtures'

class LoadFixtures < ActiveRecord::Migration
  def self.up
  	down
  	directory = File.join(File.dirname(__FILE__), 'dev_data' )
  	Fixtures.create_fixtures(directory, "neighbors" )
  	Fixtures.create_fixtures(directory, "half_blocks" )
  	Fixtures.create_fixtures(directory, "users" )
  	Fixtures.create_fixtures(directory, "roles" )

  	
  end

  def self.down
  	Neighbor.delete_all
  	HalfBlock.delete_all
  	User.delete_all
  	Role.delete_all
  end
end