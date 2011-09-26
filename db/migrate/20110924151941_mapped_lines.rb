class MappedLines < ActiveRecord::Migration
  def self.up
    create_table :mapped_lines, :force => true do |t|
        t.string "end_label"
        t.string "data"
        t.string "owner_id"
        t.string "map_layer_id"

        t.line_string "geometry", :limit => nil, :srid => 4326
        t.timestamps
    end
  end

  def self.down
    drop_table :mapped_lines
  end
end
