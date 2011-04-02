class CreateMapLayers < ActiveRecord::Migration
  def self.up
    create_table :map_layers do |t|
      t.string :name
      t.text :short_desc
      t.string :projection
      t.string :database_table
      t.string :database_column
      t.integer :opacity
      t.point :lower_left_coords
      t.point :upper_right_coords
      t.string :symbol_type
      t.string :symbol_file
      t.string :line_color
      t.string :fill_strategy
      t.string :fill_color

      t.timestamps
    end
  end

  def self.down
    drop_table :map_layers
  end
end
