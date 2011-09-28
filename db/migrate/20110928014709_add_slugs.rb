class AddSlugs < ActiveRecord::Migration
  def self.up
    add_column :theme_maps, :slug, :string
  end

  def self.down
    remove_column :theme_maps, :slug
  end
end
