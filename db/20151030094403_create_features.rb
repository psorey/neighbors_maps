class CreateFeatures < ActiveRecord::Migration
  def change
    create_table :features do |t|
      t.string :name
      t.string :guid
      t.integer :user_id
      t.integer :share_type_id
      t.point :location, srid: 3785, type: 'POINT', use_typemod: true
      t.line_string :path, srid: 3785, type: 'LINESTRING', use_typemod: true
      t.polygon :area, srid: 3785, type: "POLYGON", use_typemod: true

      t.timestamps
    end
  end
end
