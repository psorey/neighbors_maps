# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110927063444) do

  create_table "administrators", :force => true do |t|
    t.string   "admin_key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "forums", :force => true do |t|
    t.string   "forum_name"
    t.string   "forum_url"
    t.string   "forum_permissions"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "half_blocks", :force => true do |t|
    t.string        "half_block_id"
    t.string        "boundary_t"
    t.datetime      "created_at"
    t.datetime      "updated_at"
    t.multi_polygon "the_geom",      :limit => nil, :srid => 4326
    t.string        "fill_color"
  end

  create_table "map_layers", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.text     "layer_mapfile_text"
    t.integer  "opacity"
    t.string   "symbol_type"
    t.string   "symbol_file"
    t.string   "line_color"
    t.string   "fill_color"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "draw_order",         :default => 50
  end

  create_table "map_obj", :force => true do |t|
    t.string   "name"
    t.string   "shapepath"
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mapped_lines", :force => true do |t|
    t.string      "end_label"
    t.string      "data"
    t.string      "owner_id"
    t.string      "map_layer_id"
    t.datetime    "created_at"
    t.datetime    "updated_at"
    t.line_string "geometry",     :limit => nil, :srid => 4326
  end

  create_table "neighbors", :force => true do |t|
    t.string   "first_name1"
    t.string   "last_name1"
    t.string   "email_1"
    t.string   "first_name2"
    t.string   "last_name2"
    t.string   "email_2"
    t.string   "address"
    t.string   "zip"
    t.string   "half_block_id"
    t.string   "phone_1"
    t.string   "phone_2"
    t.string   "email_list"
    t.string   "block_captain"
    t.text     "volunteer"
    t.string   "resident"
    t.string   "professional"
    t.text     "interest_expertise"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "alias"
    t.string   "years"
    t.string   "sidewalks"
    t.string   "unit"
    t.text     "improvements"
    t.text     "why_walk"
    t.text     "dont_walk"
    t.date     "signup_date"
    t.integer  "user_id"
    t.point    "location",           :limit => nil, :srid => 4326
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.text     "short_desc"
    t.string   "forum_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.polygon  "project_boundary", :limit => nil, :srid => 4326
  end

  create_table "projects_users", :id => false, :force => true do |t|
    t.integer "project_id"
    t.integer "user_id"
  end

  add_index "projects_users", ["project_id"], :name => "index_projects_users_on_project_id"
  add_index "projects_users", ["user_id"], :name => "index_projects_users_on_user_id"

  create_table "roles", :force => true do |t|
    t.string "name"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  add_index "roles_users", ["role_id"], :name => "index_roles_users_on_role_id"
  add_index "roles_users", ["user_id"], :name => "index_roles_users_on_user_id"

  create_table "theme_map_layers", :force => true do |t|
    t.integer  "theme_map_id"
    t.integer  "map_layer_id"
    t.string   "line_color"
    t.string   "fill_color"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_base_layer",  :default => false
    t.integer  "opacity"
    t.integer  "line_width"
    t.boolean  "is_interactive", :default => false
  end

  create_table "theme_maps", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.text     "layers"
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "name",                      :limit => 100, :default => ""
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.integer  "neighbor_id"
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

  create_table "views", :force => true do |t|
    t.string   "owner_id"
    t.string   "published"
    t.text     "map_layer_list"
    t.float    "scale"
    t.string   "mapfile_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.point    "lower_left",     :limit => nil
    t.point    "upper_right",    :limit => nil
  end

  create_table "walk_surveys", :force => true do |t|
    t.string      "neighbor_id"
    t.text        "frequency"
    t.datetime    "created_at"
    t.datetime    "updated_at"
    t.line_string "route",       :limit => nil, :srid => 4326
  end

end
