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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120630175002) do

  create_table "money", :id => false, :force => true do |t|
    t.integer "id",                                    :null => false
    t.integer "balance",                :default => 0, :null => false
    t.string  "pin",      :limit => 10,                :null => false
    t.integer "failures",               :default => 0, :null => false
  end

  add_index "money", ["id"], :name => "index_money_on_id"

  create_table "money_history", :id => false, :force => true do |t|
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.datetime "tdate"
    t.integer  "value"
  end

  add_index "money_history", ["receiver_id"], :name => "index_money_history_on_receiver_id"
  add_index "money_history", ["sender_id"], :name => "index_money_history_on_sender_id"
  add_index "money_history", ["tdate"], :name => "index_money_history_on_tdate"

  create_table "person", :force => true do |t|
    t.string "name",   :limit => 50,                  :null => false
    t.string "gender", :limit => 1,                   :null => false
    t.string "race",   :limit => 1,  :default => "H", :null => false
  end

  add_index "person", ["id"], :name => "index_person_on_id"

  create_table "person_property", :id => false, :force => true do |t|
    t.integer "pers_id"
    t.integer "prop_id"
    t.text    "value"
  end

  add_index "person_property", ["pers_id"], :name => "index_person_property_on_pers_id"
  add_index "person_property", ["prop_id"], :name => "index_person_property_on_prop_id"

  create_table "property", :force => true do |t|
    t.string "name",   :limit => 50, :null => false
    t.string "police", :limit => 1,  :null => false
  end

  add_foreign_key "money", "person", :name => "money_id_fk", :column => "id"

  add_foreign_key "money_history", "person", :name => "money_history_receiver_id_fk", :column => "receiver_id"
  add_foreign_key "money_history", "person", :name => "money_history_sender_id_fk", :column => "sender_id"

  add_foreign_key "person_property", "person", :name => "person_property_pers_id_fk", :column => "pers_id"
  add_foreign_key "person_property", "property", :name => "person_property_prop_id_fk", :column => "prop_id"

end
