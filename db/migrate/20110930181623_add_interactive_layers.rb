class AddInteractiveLayers < ActiveRecord::Migration
  def self.up
    add_column :theme_maps, :is_interactive, :boolean, :default => false
  end

  def self.down
    remove_column :theme_maps, :is_interactive
  end
end
