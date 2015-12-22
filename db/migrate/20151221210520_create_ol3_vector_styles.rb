class CreateOl3VectorStyles < ActiveRecord::Migration
  def change
    create_table :ol3_vector_styles do |t|
      t.string :name
      t.string :alias
      t.float  :stroke_width
      t.float  :font_size
      t.string :stroke_color
      t.string :font_color
      t.string :fill_color
      t.string :style_type

      t.timestamps null: false
    end
  end
end
