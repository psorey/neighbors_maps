class CreateMapLayers < ActiveRecord::Migration
  def self.up
    create_table :map_layers do |t|
      t.string :name
      t.text :description
      t.text :layer_mapfile_text
      
      t.integer :opacity
      t.string :symbol_type
      t.string :symbol_file
      t.string :line_color
      t.string :fill_color

      t.timestamps
    end
  end

  def self.down
    drop_table :map_layers
  end
end
