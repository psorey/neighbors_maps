class CreateSources < ActiveRecord::Migration
  def change
    create_table :sources do |t|
      t.string :url
      t.string :wms_params
      t.string :source_type
      t.string :layer
      t.string :server_type

      t.timestamps null: false
    end
  end
end
