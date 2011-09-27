class AddStuffToMapLayers < ActiveRecord::Migration
  def self.up
    add_column :map_layers, :draw_order, :integer, :default => 50
  end

  def self.down
    remove_column :map_layers, :draw_order
    
  end
end
