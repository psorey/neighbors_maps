class CreateUserFeatures < ActiveRecord::Migration
  def change
    create_table :user_features do |t|
      t.integer :map_layer_id
      t.integer :user_id
      t.string :name
      t.text :text
      t.integer :number
      t.string :geometry_type
      t.geometry :geometry
      t.float :amount

      t.timestamps null: false
    end
  end
end
