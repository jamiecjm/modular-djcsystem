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

ActiveRecord::Schema.define(version: 20180611235549) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "ckeditor_assets", force: :cascade do |t|
    t.string "data_file_name", null: false
    t.string "data_content_type"
    t.integer "data_file_size"
    t.string "type", limit: 30
    t.integer "width"
    t.integer "height"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["type"], name: "index_ckeditor_assets_on_type"
  end

  create_table "commissions", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.float "percentage"
    t.date "effective_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id", "project_id"], name: "index_commissions_on_id_and_project_id"
  end

  create_table "overriding_commissions", force: :cascade do |t|
    t.integer "team_id"
    t.integer "salevalue_id"
    t.float "override"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["salevalue_id"], name: "index_overriding_commissions_on_salevalue_id"
    t.index ["team_id", "salevalue_id"], name: "index_overriding_commissions_on_team_id_and_salevalue_id", unique: true
    t.index ["team_id"], name: "index_overriding_commissions_on_team_id"
  end

  create_table "position_commissions", force: :cascade do |t|
    t.integer "position_id"
    t.integer "commission_id"
    t.float "percentage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commission_id"], name: "index_position_commissions_on_commission_id"
    t.index ["position_id", "commission_id"], name: "index_position_commissions_on_position_id_and_commission_id", unique: true
    t.index ["position_id"], name: "index_position_commissions_on_position_id"
  end

  create_table "positions", force: :cascade do |t|
    t.string "title"
    t.boolean "overriding", default: false
    t.string "ancestry"
    t.boolean "default"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ancestry"], name: "index_positions_on_ancestry"
  end

  create_table "positions_commissions", force: :cascade do |t|
    t.integer "position_id"
    t.integer "commission_id"
    t.float "percentage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commission_id"], name: "index_positions_commissions_on_commission_id"
    t.index ["position_id", "commission_id"], name: "index_positions_commissions_on_position_id_and_commission_id", unique: true
    t.index ["position_id"], name: "index_positions_commissions_on_position_id"
  end

  create_table "projects", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sales", id: :serial, force: :cascade do |t|
    t.date "date"
    t.string "buyer"
    t.integer "project_id"
    t.string "package"
    t.string "remark"
    t.date "spa_sign_date"
    t.date "la_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "commission_id"
    t.string "unit_no"
    t.integer "unit_size"
    t.float "spa_value"
    t.float "nett_value"
    t.string "status", default: "Booked"
    t.string "booking_form"
    t.index ["commission_id"], name: "index_sales_on_commission_id"
    t.index ["date"], name: "index_sales_on_date"
    t.index ["project_id"], name: "index_sales_on_project_id"
  end

  create_table "salevalues", id: :serial, force: :cascade do |t|
    t.float "percentage"
    t.float "nett_value"
    t.float "spa"
    t.float "comm"
    t.integer "user_id"
    t.integer "sale_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "order"
    t.string "other_user"
    t.integer "team_id"
    t.index ["sale_id"], name: "index_salevalues_on_sale_id"
    t.index ["user_id"], name: "index_salevalues_on_user_id"
  end

  create_table "teams", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.string "ancestry"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "effective_date"
    t.integer "position_id"
    t.integer "upline_id"
    t.boolean "hidden", default: true
    t.boolean "current", default: true
    t.index ["ancestry"], name: "index_teams_on_ancestry"
    t.index ["upline_id"], name: "index_teams_on_upline_id"
    t.index ["user_id"], name: "index_teams_on_user_id"
  end

  create_table "teams_positions", force: :cascade do |t|
    t.integer "team_id"
    t.integer "position_id"
    t.date "effective_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["position_id"], name: "index_teams_positions_on_position_id"
    t.index ["team_id", "position_id"], name: "index_teams_positions_on_team_id_and_position_id", unique: true
    t.index ["team_id"], name: "index_teams_positions_on_team_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email"
    t.string "encrypted_password"
    t.string "name"
    t.string "prefered_name", null: false
    t.string "phone_no"
    t.date "birthday"
    t.integer "team_id"
    t.string "ancestry"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false
    t.boolean "archived", default: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "locked_at"
    t.string "ic_no"
    t.string "location"
    t.integer "referrer_id"
    t.integer "upline_id"
    t.index ["ancestry"], name: "index_users_on_ancestry"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["prefered_name"], name: "index_users_on_prefered_name"
    t.index ["referrer_id"], name: "index_users_on_referrer_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["team_id"], name: "index_users_on_team_id"
    t.index ["upline_id"], name: "index_users_on_upline_id"
  end

  create_table "websites", id: :serial, force: :cascade do |t|
    t.string "subdomain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "superteam_name"
    t.string "logo"
    t.string "external_host"
    t.string "email"
    t.string "password"
    t.string "password_digest"
  end

end
