class AddSourceToMapLayer < ActiveRecord::Migration
  def change
    add_column :map_layers, :source_url, :string
    add_column :map_layers, :source_type, :string
    add_column :map_layers, :source_server_type, :string
    add_column :map_layers, :source_layer, :string
    add_column :map_layers, :is_local_mapserver, :boolean

  end
end
