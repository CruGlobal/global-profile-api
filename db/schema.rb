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

ActiveRecord::Schema.define(version: 20160331201240) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "areas", force: :cascade do |t|
    t.uuid     "gr_id"
    t.string   "name"
    t.string   "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "areas", ["code"], name: "index_areas_on_code", unique: true, using: :btree
  add_index "areas", ["gr_id"], name: "index_areas_on_gr_id", unique: true, using: :btree

  create_table "countries", force: :cascade do |t|
    t.string   "iso_code"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "countries", ["iso_code"], name: "index_countries_on_iso_code", unique: true, using: :btree

  create_table "ministries", force: :cascade do |t|
    t.uuid     "gr_id"
    t.string   "name"
    t.string   "min_code"
    t.string   "gp_key"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "area_id"
    t.boolean  "active",     default: false, null: false
  end

  add_index "ministries", ["gr_id"], name: "index_ministries_on_gr_id", unique: true, using: :btree
  add_index "ministries", ["min_code"], name: "index_ministries_on_min_code", unique: true, using: :btree

  add_foreign_key "ministries", "areas", on_update: :cascade, on_delete: :nullify
end
