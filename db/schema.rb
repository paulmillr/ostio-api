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

ActiveRecord::Schema.define(version: 20160303030300) do

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0
    t.integer  "attempts",   limit: 4,     default: 0
    t.text     "handler",    limit: 65535
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "organization_owners", force: :cascade do |t|
    t.integer "owner_id",        limit: 4
    t.integer "organization_id", limit: 4
  end

  add_index "organization_owners", ["organization_id"], name: "organization_owners_organization_id_fk", using: :btree
  add_index "organization_owners", ["owner_id"], name: "organization_owners_owner_id_fk", using: :btree

  create_table "posts", force: :cascade do |t|
    t.integer  "topic_id",   limit: 4,     null: false
    t.integer  "user_id",    limit: 4,     null: false
    t.text     "text",       limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "posts", ["topic_id"], name: "posts_topic_id_fk", using: :btree
  add_index "posts", ["user_id"], name: "posts_user_id_fk", using: :btree

  create_table "repos", force: :cascade do |t|
    t.integer  "user_id",    limit: 4,   null: false
    t.integer  "github_id",  limit: 4
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "repos", ["user_id"], name: "repos_user_id_fk", using: :btree

  create_table "topics", force: :cascade do |t|
    t.integer  "repo_id",    limit: 4,   null: false
    t.integer  "user_id",    limit: 4,   null: false
    t.integer  "number",     limit: 4,   null: false
    t.string   "title",      limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "topics", ["number"], name: "index_topics_on_number", using: :btree
  add_index "topics", ["repo_id"], name: "topics_repo_id_fk", using: :btree
  add_index "topics", ["user_id"], name: "topics_user_id_fk", using: :btree

  create_table "users", force: :cascade do |t|
    t.integer  "github_id",                   limit: 4
    t.string   "login",                       limit: 255
    t.string   "authentication_token",        limit: 255
    t.string   "name",                        limit: 255
    t.string   "email",                       limit: 255, default: ""
    t.string   "gravatar_id",                 limit: 255
    t.string   "typeof",                      limit: 255
    t.string   "github_token",                limit: 255
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.boolean  "enabled_email_notifications",             default: false
    t.string   "avatar_url",                  limit: 255
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["login"], name: "index_users_on_login", unique: true, using: :btree

  add_foreign_key "organization_owners", "users", column: "organization_id", name: "organization_owners_organization_id_fk"
  add_foreign_key "organization_owners", "users", column: "owner_id", name: "organization_owners_owner_id_fk"
  add_foreign_key "posts", "topics", name: "posts_topic_id_fk"
  add_foreign_key "posts", "users", name: "posts_user_id_fk"
  add_foreign_key "repos", "users", name: "repos_user_id_fk"
  add_foreign_key "topics", "repos", name: "topics_repo_id_fk"
  add_foreign_key "topics", "users", name: "topics_user_id_fk"
end
