class AddColor < ActiveRecord::Migration
  def self.up
    add_column :half_blocks, :fill_color, :string
  end

  def self.down
    remove_column :half_blocks, :fill_color
  end
end
