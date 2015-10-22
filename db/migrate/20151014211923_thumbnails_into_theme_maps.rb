class ThumbnailsIntoThemeMaps < ActiveRecord::Migration
  def change
    add_column :theme_maps, :thumbnail_url, :string
  end
end
