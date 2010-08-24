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

ActiveRecord::Schema.define(:version => 20100823232950) do

  create_table "administrators", :force => true do |t|
    t.string   "admin_key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "half_blocks", :force => true do |t|
    t.string        "half_block_id"
    t.string        "boundary_t"
    t.datetime      "created_at"
    t.datetime      "updated_at"
    t.multi_polygon "the_geom",      :limit => nil, :srid => 4326
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
    t.point    "location",           :limit => nil, :srid => 4326
    t.string   "alias"
    t.string   "years"
    t.string   "sidewalks"
    t.string   "unit"
    t.text     "improvements"
    t.text     "why_walk"
    t.text     "dont_walk"
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
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end