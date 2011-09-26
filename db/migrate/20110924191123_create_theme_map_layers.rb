class CreateThemeMapLayers < ActiveRecord::Migration
  def self.up
    create_table :theme_map_layers do |t|
      t.integer :theme_map_id
      t.integer :map_layer_id
      t.string :line_color
      t.string :fill_color

      t.timestamps
    end
  end

  def self.down
    drop_table :theme_map_layers
  end
end
