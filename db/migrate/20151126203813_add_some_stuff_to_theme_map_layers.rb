class AddSomeStuffToThemeMapLayers < ActiveRecord::Migration
  def change
    add_column :theme_map_layers, :draw_order, :integer
    remove_column :map_layers, :draw_order
  end
end
