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

ActiveRecord::Schema.define(:version => 0) do

  create_table "money", :id => false, :force => true do |t|
    t.decimal "id",                    :precision => 10, :scale => 0,                :null => false
    t.decimal "balance",               :precision => 15, :scale => 0, :default => 0, :null => false
    t.string  "pin",      :limit => 5,                                               :null => false
    t.decimal "failures",              :precision => 1,  :scale => 0, :default => 0, :null => false
  end

  create_table "money_history", :id => false, :force => true do |t|
    t.decimal  "sender_id",   :precision => 10, :scale => 0, :null => false
    t.decimal  "receiver_id", :precision => 10, :scale => 0, :null => false
    t.datetime "tdate",                                      :null => false
    t.decimal  "value",       :precision => 15, :scale => 0, :null => false
  end

  create_table "person", :id => false, :force => true do |t|
    t.decimal "id",                   :precision => 10, :scale => 0,                  :null => false
    t.string  "name",   :limit => 50,                                                 :null => false
    t.string  "gender", :limit => 1,                                                  :null => false
    t.string  "race",   :limit => 1,                                 :default => "H", :null => false
  end

  create_table "person_prop", :id => false, :force => true do |t|
    t.decimal "prop_id",                 :precision => 10, :scale => 0, :null => false
    t.decimal "pers_id",                 :precision => 10, :scale => 0, :null => false
    t.string  "value",   :limit => 4096,                                :null => false
  end

  create_table "property", :force => true do |t|
    t.string "name",   :limit => 50,                  :null => false
    t.string "police", :limit => 1,  :default => "N"
  end

  create_table "stock_company", :id => false, :force => true do |t|
    t.string  "key",          :limit => 5,                                                       :null => false
    t.string  "name",         :limit => 100,                                                     :null => false
    t.decimal "total_stock",                 :precision => 10, :scale => 0, :default => 1000000, :null => false
    t.string  "status",       :limit => 1,                                  :default => "A",     :null => false
    t.decimal "market_stock",                :precision => 10, :scale => 0, :default => 150000,  :null => false
  end

  create_table "stock_cycle", :force => true do |t|
    t.datetime "start_time",   :null => false
    t.datetime "border1_time", :null => false
    t.datetime "border2_time", :null => false
    t.datetime "finish_time",  :null => false
  end

  create_table "stock_history", :id => false, :force => true do |t|
    t.decimal  "sender_id",                :precision => 10, :scale => 0, :null => false
    t.decimal  "receiver_id",              :precision => 10, :scale => 0, :null => false
    t.string   "company_key", :limit => 5,                                :null => false
    t.datetime "tdate",                                                   :null => false
    t.decimal  "qty",                      :precision => 10, :scale => 0, :null => false
    t.decimal  "price",                    :precision => 10, :scale => 0, :null => false
  end

  create_table "stock_news", :force => true do |t|
    t.datetime "publish_time",                 :null => false
    t.string   "title",        :limit => 200,  :null => false
    t.string   "ntext",        :limit => 2000, :null => false
  end

  create_table "stock_owner", :id => false, :force => true do |t|
    t.decimal "person_id",              :precision => 10, :scale => 0,                :null => false
    t.string  "key",       :limit => 5,                                               :null => false
    t.decimal "quantity",               :precision => 10, :scale => 0, :default => 0, :null => false
  end

  create_table "stock_quote", :id => false, :force => true do |t|
    t.decimal "cycle_id",                 :precision => 5,  :scale => 0,                     :null => false
    t.string  "company_key", :limit => 5,                                                    :null => false
    t.decimal "price",                    :precision => 10, :scale => 0,                     :null => false
    t.decimal "trade_limit",              :precision => 10, :scale => 0, :default => 150000, :null => false
    t.decimal "npcs_buy",                 :precision => 10, :scale => 0, :default => 100000, :null => false
  end

  create_table "stock_request", :force => true do |t|
    t.decimal  "person_id",                :precision => 10, :scale => 0,                  :null => false
    t.decimal  "cycle_id",                 :precision => 5,  :scale => 0,                  :null => false
    t.string   "company_key", :limit => 5,                                                 :null => false
    t.datetime "rtime",                                                                    :null => false
    t.string   "status",      :limit => 1,                                :default => "A", :null => false
    t.string   "operation",   :limit => 1,                                                 :null => false
    t.decimal  "quantity",                 :precision => 10, :scale => 0,                  :null => false
  end

  create_table "vk_answer", :id => false, :force => true do |t|
    t.decimal "question_id",                   :precision => 10, :scale => 0,                :null => false
    t.decimal "id",                            :precision => 10, :scale => 0,                :null => false
    t.string  "text",          :limit => 1024,                                               :null => false
    t.integer "human_value",                                                  :default => 0, :null => false
    t.integer "android_value",                                                :default => 0, :null => false
  end

  create_table "vk_question", :force => true do |t|
    t.string "text",   :limit => 1024,                  :null => false
    t.string "gender", :limit => 1,    :default => "A", :null => false
  end

  create_table "vk_session", :force => true do |t|
    t.decimal  "person_id",               :precision => 10, :scale => 0,                  :null => false
    t.datetime "start_date",                                                              :null => false
    t.decimal  "device_id",               :precision => 5,  :scale => 0,                  :null => false
    t.string   "status",     :limit => 1,                                :default => "A", :null => false
  end

  create_table "vk_session_answer", :id => false, :force => true do |t|
    t.decimal  "session_id",  :precision => 10, :scale => 0, :null => false
    t.decimal  "question_id", :precision => 10, :scale => 0, :null => false
    t.decimal  "answer_id",   :precision => 10, :scale => 0, :null => false
    t.datetime "atime",                                      :null => false
  end

  create_table "vk_session_question", :id => false, :force => true do |t|
    t.decimal  "session_id",  :precision => 10, :scale => 0, :null => false
    t.decimal  "question_id", :precision => 10, :scale => 0, :null => false
    t.datetime "qtime",                                      :null => false
  end

end
