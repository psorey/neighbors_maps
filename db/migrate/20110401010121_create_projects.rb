class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.string :name
      t.text :short_desc
      t.string :forum_url
      t.string :wiki_url
      t.polygon :project_boundary, :srid => '4326'

      t.timestamps
    end
    # generate the join table
    create_table "projects_users", :id => false do |t|
      t.integer :project_id, :user_id
    end
    add_index "projects_users", :project_id
    add_index "projects_users", :user_id

  end
  

  def self.down
    drop_table :projects
    drop_table :projects_users
  end
end
