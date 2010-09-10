class AddToNeighbors < ActiveRecord::Migration
  def self.up
    add_column :neighbors, :alias, :string
    add_column :neighbors, :years, :string
    add_column :neighbors, :sidewalks, :string
    add_column :neighbors, :unit, :string
    add_column :neighbors, :improvements, :text
    add_column :neighbors, :why_walk, :text
    add_column :neighbors, :dont_walk, :text
    add_column :neighbors, :signup_date, :date
    change_column :neighbors, :volunteer, :text 
  end

  def self.down
    remove_column :neighbors, :alias
    remove_column :neighbors, :sidewalks
    remove_column :neighbors, :years
    remove_column :neighbors, :unit
    remove_column :neighbors, :improvements
    remove_column :neighbors, :why_walk
    remove_column :neighbors, :dont_walk
    remove_column :neighbors, :signup_date
    change_column :neighbors, :volunteer, :string
  end
end
