class CreateVectorFeatures < ActiveRecord::Migration
  def change
    create_table :vector_features do |t|
      t.string :guid
      t.integer :map_layer_id
      t.integer :user_id
      t.string :vector_type
      t.text :text
      t.string :value
      t.float :amount
      t.integer :number
      t.geometry :geometry
      t.timestamps null: false
    end

    drop_table :walk_surveys
  end
end
