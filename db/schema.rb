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

ActiveRecord::Schema.define(version: 20160407205155) do

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

  create_table "assignments", force: :cascade do |t|
    t.integer  "person_id"
    t.integer  "ministry_id"
    t.uuid     "gr_id"
    t.integer  "mcc",           default: 0, null: false
    t.integer  "position_role", default: 0, null: false
    t.integer  "scope",         default: 0, null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "assignments", ["gr_id"], name: "index_assignments_on_gr_id", unique: true, using: :btree
  add_index "assignments", ["ministry_id"], name: "index_assignments_on_ministry_id", using: :btree
  add_index "assignments", ["person_id"], name: "index_assignments_on_person_id", using: :btree

  create_table "countries", force: :cascade do |t|
    t.string   "iso_code"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "countries", ["iso_code"], name: "index_countries_on_iso_code", unique: true, using: :btree

  create_table "email_addresses", force: :cascade do |t|
    t.uuid     "gr_id"
    t.integer  "person_id"
    t.string   "email"
    t.boolean  "primary",    default: false, null: false
    t.string   "location"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "email_addresses", ["gr_id"], name: "index_email_addresses_on_gr_id", unique: true, using: :btree
  add_index "email_addresses", ["person_id"], name: "index_email_addresses_on_person_id", using: :btree

  create_table "employments", force: :cascade do |t|
    t.integer  "person_id"
    t.integer  "ministry_id"
    t.uuid     "gr_id"
    t.date     "date_joined_staff"
    t.date     "date_left_staff"
    t.integer  "organizational_status", default: 0, null: false
    t.integer  "funding_source",        default: 0, null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "employments", ["gr_id"], name: "index_employments_on_gr_id", unique: true, using: :btree
  add_index "employments", ["ministry_id"], name: "index_employments_on_ministry_id", using: :btree
  add_index "employments", ["person_id"], name: "index_employments_on_person_id", using: :btree

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

  create_table "people", force: :cascade do |t|
    t.uuid     "gr_id"
    t.integer  "ministry_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "preferred_name"
    t.integer  "gender",                         default: 0,     null: false
    t.date     "birth_date"
    t.integer  "marital_status",                 default: 0,     null: false
    t.string   "language",                       default: [],                 array: true
    t.uuid     "key_guid"
    t.boolean  "approved",                       default: true,  null: false
    t.boolean  "is_secure",                      default: false, null: false
    t.string   "country_of_residence", limit: 3
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  add_index "people", ["gr_id", "ministry_id"], name: "index_people_on_gr_id_and_ministry_id", unique: true, using: :btree
  add_index "people", ["ministry_id"], name: "index_people_on_ministry_id", using: :btree

  create_table "user_roles", force: :cascade do |t|
    t.uuid     "key_guid",               null: false
    t.uuid     "ministry",               null: false
    t.integer  "role",       default: 0, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "user_roles", ["key_guid", "ministry"], name: "index_user_roles_on_key_guid_and_ministry", unique: true, using: :btree

  add_foreign_key "assignments", "ministries", on_update: :cascade, on_delete: :restrict
  add_foreign_key "assignments", "people", on_update: :cascade, on_delete: :restrict
  add_foreign_key "email_addresses", "people", on_update: :cascade, on_delete: :cascade
  add_foreign_key "employments", "ministries"
  add_foreign_key "employments", "people"
  add_foreign_key "ministries", "areas", on_update: :cascade, on_delete: :nullify
  add_foreign_key "people", "ministries", on_update: :cascade, on_delete: :restrict
end
