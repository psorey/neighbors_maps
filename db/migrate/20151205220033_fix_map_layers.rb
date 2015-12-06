class FixMapLayers < ActiveRecord::Migration
  def change
    remove_column :map_layers, :source
    add_column :map_layers, :source_id, :integer
    remove_column :map_layers, :mapserver
  end
end
