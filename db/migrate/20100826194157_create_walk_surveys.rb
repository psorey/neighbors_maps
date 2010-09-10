class CreateWalkSurveys < ActiveRecord::Migration
  def self.up
    create_table :walk_surveys do |t|
      t.string :neighbor_id
      t.text :frequency
      t.line_string :route, :srid => 4326

      t.timestamps
    end
  end

  def self.down
    drop_table :walk_surveys
  end
end
