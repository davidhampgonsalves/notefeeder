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

ActiveRecord::Schema.define(:version => 20101005215132) do

  create_table "lists", :force => true do |t|
    t.string   "name"
    t.string   "user"
    t.datetime "created_at"
    t.boolean  "deleted",        :default => false
    t.datetime "deleted_since"
    t.boolean  "has_public_url", :default => true,  :null => false
  end

  add_index "lists", ["user", "name"], :name => "index_lists_on_user_and_name", :unique => true
  add_index "lists", ["user"], :name => "index_lists_on_user"

  create_table "notes", :force => true do |t|
    t.integer "list_id",                        :null => false
    t.string  "title"
    t.text    "description"
    t.text    "url"
    t.boolean "is_private",  :default => false, :null => false
    t.boolean "completed",   :default => false, :null => false
  end

  add_index "notes", ["list_id", "id"], :name => "index_notes_on_list_id_and_id"
  add_index "notes", [nil, "list_id"], :name => "notes_tsearch_index"

  create_table "open_id_associations", :force => true do |t|
    t.binary  "server_url"
    t.string  "handle"
    t.binary  "secret"
    t.integer "issued"
    t.integer "lifetime"
    t.string  "assoc_type"
  end

  create_table "open_id_nonces", :force => true do |t|
    t.string  "server_url", :null => false
    t.integer "timestamp",  :null => false
    t.string  "salt",       :null => false
  end

  create_table "users", :force => true do |t|
    t.string "user_openid"
    t.string "user"
  end

  add_index "users", ["user_openid"], :name => "index_users_on_user_openid"

end
