require 'spatial_adapter/postgresql'

class CreateHalfBlocks < ActiveRecord::Migration
  def self.up
    create_table :half_blocks do |t|
      t.multi_polygon :the_geom, :srid => 4326
      t.string :half_block_id
      t.string :boundary_t
      t.timestamps
    end
  end

  def self.down
    drop_table :half_blocks
  end
end
