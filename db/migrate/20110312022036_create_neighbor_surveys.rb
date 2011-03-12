class CreateNeighborSurveys < ActiveRecord::Migration
  def self.up
    create_table :neighbor_surveys do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :neighbor_surveys
  end
end
