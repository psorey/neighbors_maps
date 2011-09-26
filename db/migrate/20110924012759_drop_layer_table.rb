class DropLayerTable < ActiveRecord::Migration
  def self.up
    drop_table :mapped_lines
  end

  def self.down
  end
end
