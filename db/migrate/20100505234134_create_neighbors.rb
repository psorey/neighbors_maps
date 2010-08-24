require 'spatial_adapter/postgresql'

class CreateNeighbors < ActiveRecord::Migration
  def self.up
    create_table :neighbors do |t|
      t.point  :location, :srid => 4326
      t.string :first_name1
      t.string :last_name1
      t.string :email_1
      t.string :first_name2
      t.string :last_name2
      t.string :email_2
      t.string :address
      t.string :zip
      t.string :half_block_id
      t.string :phone_1
      t.string :phone_2
      t.string :email_list
      t.string :block_captain
      t.string :volunteer
      t.string :resident
      t.string :professional
      t.text :interest_expertise
      t.timestamps
    end
  end

  def self.down
    drop_table :neighbors
  end
end
