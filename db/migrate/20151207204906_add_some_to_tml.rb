class AddSomeToTml < ActiveRecord::Migration
  def change
    add_column :theme_map_layers, :visible, :boolean
  end
end
