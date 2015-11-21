# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151111013547) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "administrators", force: :cascade do |t|
    t.string   "admin_key",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "forums", force: :cascade do |t|
    t.string   "forum_name",        limit: 255
    t.string   "forum_url",         limit: 255
    t.string   "forum_permissions", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "half_blocks", force: :cascade do |t|
    t.string   "half_block_id", limit: 255
    t.string   "boundary_t",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "fill_color",    limit: 255
    t.geometry "the_geom",      limit: {:srid=>4326, :type=>"multi_polygon"}
  end

  create_table "map_layers", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.text     "description"
    t.text     "layer_mapfile_text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "draw_order",                     default: 50
    t.string   "srs",                limit: 255
    t.string   "url_extension",      limit: 255
    t.string   "template_file",      limit: 255
    t.string   "projection",         limit: 255
    t.string   "wkt_extent",         limit: 255
    t.string   "units",              limit: 255
  end

  create_table "neighbors", force: :cascade do |t|
    t.string   "first_name1",        limit: 255
    t.string   "last_name1",         limit: 255
    t.string   "email_1",            limit: 255
    t.string   "first_name2",        limit: 255
    t.string   "last_name2",         limit: 255
    t.string   "email_2",            limit: 255
    t.string   "address",            limit: 255
    t.string   "zip",                limit: 255
    t.string   "half_block_id",      limit: 255
    t.string   "phone_1",            limit: 255
    t.string   "phone_2",            limit: 255
    t.string   "email_list",         limit: 255
    t.string   "block_captain",      limit: 255
    t.text     "volunteer"
    t.string   "resident",           limit: 255
    t.string   "professional",       limit: 255
    t.text     "interest_expertise"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "alias",              limit: 255
    t.string   "years",              limit: 255
    t.string   "sidewalks",          limit: 255
    t.string   "unit",               limit: 255
    t.text     "improvements"
    t.text     "why_walk"
    t.text     "dont_walk"
    t.date     "signup_date"
    t.integer  "user_id"
    t.geometry "location",           limit: {:srid=>4326, :type=>"point"}
  end

  create_table "projects", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.text     "short_desc"
    t.string   "forum_url",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.geometry "project_boundary", limit: {:srid=>4326, :type=>"polygon"}
  end

  create_table "projects_users", id: false, force: :cascade do |t|
    t.integer "project_id"
    t.integer "user_id"
  end

  add_index "projects_users", ["project_id"], name: "index_projects_users_on_project_id", using: :btree
  add_index "projects_users", ["user_id"], name: "index_projects_users_on_user_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "roles_users", id: false, force: :cascade do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  add_index "roles_users", ["role_id"], name: "index_roles_users_on_role_id", using: :btree
  add_index "roles_users", ["user_id"], name: "index_roles_users_on_user_id", using: :btree

  create_table "theme_map_layers", force: :cascade do |t|
    t.integer  "theme_map_id"
    t.integer  "map_layer_id"
    t.string   "line_color",     limit: 255
    t.string   "fill_color",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_base_layer",              default: false
    t.integer  "opacity"
    t.integer  "line_width"
    t.boolean  "is_interactive",             default: false
    t.string   "name",           limit: 255
  end

  create_table "theme_maps", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_interactive",             default: false
    t.string   "thumbnail_url",  limit: 255
    t.string   "slug",           limit: 255
  end

  create_table "user_lines", force: :cascade do |t|
    t.string   "properties",   limit: 255
    t.integer  "map_layer_id"
    t.integer  "user_id"
    t.geometry "geometry",     limit: {:srid=>3857, :type=>"line_string"}
    t.string   "guid"
    t.string   "name"
    t.text     "text"
    t.integer  "number"
    t.float    "amount"
  end

  create_table "users", force: :cascade do |t|
    t.string   "login",                     limit: 40
    t.string   "name",                      limit: 100, default: ""
    t.string   "email",                     limit: 100
    t.string   "crypted_password",          limit: 40
    t.string   "salt",                      limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            limit: 40
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           limit: 40
    t.datetime "activated_at"
    t.integer  "neighbor_id"
  end

  add_index "users", ["login"], name: "index_users_on_login", unique: true, using: :btree

  create_table "walk_surveys", force: :cascade do |t|
    t.string   "neighbor_id", limit: 255
    t.text     "frequency"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.geometry "route",       limit: {:srid=>4326, :type=>"line_string"}
  end

end
