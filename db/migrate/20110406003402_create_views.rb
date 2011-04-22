class CreateViews < ActiveRecord::Migration
  def self.up
    create_table :views do |t|
      t.string :owner_id
      t.string :published
      t.text :map_layer_list
      t.float :scale
      t.point :lower_left
      t.point :upper_right
      t.string :mapfile_name

      t.timestamps
    end
  end

  def self.down
    drop_table :views
  end
end
