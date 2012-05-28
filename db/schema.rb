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

ActiveRecord::Schema.define(:version => 20120528134218) do

  create_table "organizationings", :force => true do |t|
    t.integer "owner_id"
    t.integer "organization_id"
  end

  add_index "organizationings", ["organization_id"], :name => "organizationings_organization_id_fk"
  add_index "organizationings", ["owner_id"], :name => "organizationings_owner_id_fk"

  create_table "posts", :force => true do |t|
    t.integer  "topic_id",   :null => false
    t.integer  "user_id",    :null => false
    t.text     "text"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "posts", ["topic_id"], :name => "posts_topic_id_fk"
  add_index "posts", ["user_id"], :name => "posts_user_id_fk"

  create_table "repos", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "github_id"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "repos", ["user_id"], :name => "repos_user_id_fk"

  create_table "topics", :force => true do |t|
    t.integer  "repo_id",    :null => false
    t.integer  "user_id",    :null => false
    t.integer  "number",     :null => false
    t.string   "title",      :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "topics", ["number"], :name => "index_topics_on_number"
  add_index "topics", ["repo_id"], :name => "topics_repo_id_fk"
  add_index "topics", ["user_id"], :name => "topics_user_id_fk"

  create_table "users", :force => true do |t|
    t.integer  "github_id"
    t.string   "login"
    t.string   "authentication_token"
    t.string   "name"
    t.string   "email",                :default => "", :null => false
    t.string   "gravatar_id"
    t.string   "type"
    t.string   "github_token"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

  add_foreign_key "organizationings", "users", :name => "organizationings_organization_id_fk", :column => "organization_id"
  add_foreign_key "organizationings", "users", :name => "organizationings_owner_id_fk", :column => "owner_id"

  add_foreign_key "posts", "topics", :name => "posts_topic_id_fk"
  add_foreign_key "posts", "users", :name => "posts_user_id_fk"

  add_foreign_key "repos", "users", :name => "repos_user_id_fk"

  add_foreign_key "topics", "repos", :name => "topics_repo_id_fk"
  add_foreign_key "topics", "users", :name => "topics_user_id_fk"

end
