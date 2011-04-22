class CreateForums < ActiveRecord::Migration
  def self.up
    create_table :forums do |t|
      t.string :forum_name
      t.string :forum_url
      t.string :forum_permissions

      t.timestamps
    end
  end

  def self.down
    drop_table :forums
  end
end
