class AddLocalMapserver < ActiveRecord::Migration
  def change
    add_column :map_layers, :mapserver, :boolean
  end
end
