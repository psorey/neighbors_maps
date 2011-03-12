class CreateLabeledLines < ActiveRecord::Migration
  def self.up
    create_table :labeled_lines do |t|
      t.line_string :geometry
      t.string :label

      t.timestamps
    end
  end

  def self.down
    drop_table :labeled_lines
  end
end
