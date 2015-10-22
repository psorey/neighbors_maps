class BlahDeBlah2 < ActiveRecord::Migration
  def change
    add_column :theme_maps, :slug, :string
  end
end
