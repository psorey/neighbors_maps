class AddLotsToMapLayers < ActiveRecord::Migration

  def change
    add_column :map_layers, :srs, :string
    add_column :map_layers, :url_extension, :string
    add_column :map_layers, :template_file, :string
    add_column :map_layers, :projection, :string
    add_column :map_layers, :wkt_extent, :string
    add_column :map_layers, :units, :string

    add_column :theme_map_layers, :name, :string

  end

end
