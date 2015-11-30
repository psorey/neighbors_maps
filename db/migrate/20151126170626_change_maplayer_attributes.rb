class ChangeMaplayerAttributes < ActiveRecord::Migration
  def change
    remove_column :map_layers, :projection
    add_column :map_layers, :data_mapfile, :string
    add_column :map_layers, :source, :string
    add_column :map_layers, :geometry_type, :string
    add_column :theme_map_layers, :layer_type, :string
  end
end
