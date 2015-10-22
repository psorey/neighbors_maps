class BlahDeBlah < ActiveRecord::Migration
  def change
    remove_column :theme_maps, :slug
  end
end
