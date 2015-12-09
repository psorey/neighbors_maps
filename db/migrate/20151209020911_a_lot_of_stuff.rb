class ALotOfStuff < ActiveRecord::Migration
  def change
    remove_column :theme_map_layers, :name
    remove_column :theme_map_layers, :line_color
    remove_column :theme_map_layers, :fill_color
    remove_column :theme_map_layers, :line_width
  end
end

