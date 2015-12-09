class AddTitleToTml < ActiveRecord::Migration
  def change
    add_column :theme_map_layers, :title, :string
  end
end
