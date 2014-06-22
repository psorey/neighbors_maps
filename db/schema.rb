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

ActiveRecord::Schema.define(version: 20140619045419) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"
  enable_extension "postgis_topology"
  enable_extension "adminpack"

  create_table "half_blocks", force: true do |t|
    t.string   "half_block_id"
    t.string   "boundary_t"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "fill_color"
    t.spatial  "the_geom",      limit: {:srid=>4326, :type=>"multi_polygon"}
  end

  create_table "map_layers", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.text     "layer_mapfile_text"
    t.integer  "draw_order",         default: 50
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mapped_lines", force: true do |t|
    t.string   "end_label"
    t.string   "data"
    t.string   "owner_id"
    t.string   "map_layer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.spatial  "geometry",     limit: {:srid=>4326, :type=>"line_string"}
  end

  create_table "neighbors", force: true do |t|
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
    t.spatial  "location",           limit: {:srid=>4326, :type=>"point"}
  end

  create_table "theme_map_layers", force: true do |t|
    t.integer  "theme_map_id"
    t.integer  "map_layer_id"
    t.string   "line_color"
    t.string   "fill_color"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_base_layer",  default: false
    t.integer  "opacity"
    t.integer  "line_width"
    t.boolean  "is_interactive", default: false
  end

  create_table "theme_maps", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
    t.boolean  "is_interactive", default: false
  end

  create_table "walk_surveys", force: true do |t|
    t.string   "neighbor_id"
    t.text     "frequency"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.spatial  "route",       limit: {:srid=>4326, :type=>"line_string"}
  end

end
