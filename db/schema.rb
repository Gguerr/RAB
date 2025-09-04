# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_09_03_212121) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "employees", force: :cascade do |t|
    t.string "identification_number", null: false
    t.string "names", null: false
    t.string "surnames", null: false
    t.date "birth_date", null: false
    t.date "hire_date", null: false
    t.text "home_address"
    t.date "vacation_date"
    t.integer "expired_vacations", default: 0
    t.text "skills_abilities"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["identification_number"], name: "index_employees_on_identification_number", unique: true
  end

  create_table "family_members", force: :cascade do |t|
    t.bigint "employee_id", null: false
    t.string "names"
    t.date "birth_date"
    t.string "education_level"
    t.string "relationship"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_family_members_on_employee_id"
  end

  create_table "party_cards", force: :cascade do |t|
    t.bigint "employee_id", null: false
    t.string "code"
    t.string "serial_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_party_cards_on_employee_id"
  end

  create_table "payment_accounts", force: :cascade do |t|
    t.bigint "employee_id", null: false
    t.string "account_type", null: false
    t.string "account_number"
    t.string "mobile_payment_number"
    t.string "bank_name"
    t.boolean "is_primary", default: false
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id", "is_primary"], name: "index_payment_accounts_on_employee_id_and_is_primary"
    t.index ["employee_id"], name: "index_payment_accounts_on_employee_id"
  end

  create_table "psuv_cards", force: :cascade do |t|
    t.bigint "employee_id", null: false
    t.string "code"
    t.string "serial_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_psuv_cards_on_employee_id"
  end

  create_table "worker_sizes", force: :cascade do |t|
    t.bigint "employee_id", null: false
    t.string "shirt_size"
    t.string "shoes_size"
    t.string "pants_size"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_worker_sizes_on_employee_id"
  end

  add_foreign_key "family_members", "employees"
  add_foreign_key "party_cards", "employees"
  add_foreign_key "payment_accounts", "employees"
  add_foreign_key "psuv_cards", "employees"
  add_foreign_key "worker_sizes", "employees"
end
