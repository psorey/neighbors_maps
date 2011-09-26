class CreateThemeMaps < ActiveRecord::Migration
  def self.up
    create_table :theme_maps do |t|
      t.string :name
      t.text :description
      t.text :layers
      t.integer :width
      t.integer :height

      t.timestamps
    end
  end

  def self.down
    drop_table :theme_maps
  end
end
