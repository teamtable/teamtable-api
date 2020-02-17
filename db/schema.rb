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

ActiveRecord::Schema.define(version: 2019_04_21_110141) do

  create_table "assignments", force: :cascade do |t|
    t.integer "user_id"
    t.integer "card_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "doing", default: false
    t.index ["card_id", "user_id"], name: "index_assignments_on_card_id_and_user_id", unique: true
    t.index ["card_id"], name: "index_assignments_on_card_id"
    t.index ["user_id"], name: "index_assignments_on_user_id"
  end

  create_table "attachments", force: :cascade do |t|
    t.integer "card_id"
    t.integer "tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["card_id"], name: "index_attachments_on_card_id"
    t.index ["tag_id", "card_id"], name: "index_attachments_on_tag_id_and_card_id", unique: true
    t.index ["tag_id"], name: "index_attachments_on_tag_id"
  end

  create_table "card_positions", force: :cascade do |t|
    t.integer "card_id"
    t.integer "user_id"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["card_id", "user_id"], name: "index_card_positions_on_card_id_and_user_id", unique: true
    t.index ["card_id"], name: "index_card_positions_on_card_id"
    t.index ["position", "user_id", "card_id"], name: "index_card_positions_on_position_and_user_id_and_card_id", unique: true
    t.index ["user_id"], name: "index_card_positions_on_user_id"
  end

  create_table "cards", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.integer "state", default: 0
    t.integer "priority", default: 0
    t.datetime "deadline"
    t.integer "created_by_id"
    t.integer "completed_by_id"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "list_id"
    t.index ["completed_by_id"], name: "index_cards_on_completed_by_id"
    t.index ["created_by_id"], name: "index_cards_on_created_by_id"
    t.index ["list_id"], name: "index_cards_on_list_id"
  end

  create_table "jwt_blacklists", force: :cascade do |t|
    t.string "jti", null: false
    t.datetime "exp", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_blacklists_on_jti"
  end

  create_table "list_attachments", force: :cascade do |t|
    t.integer "list_id"
    t.integer "tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["list_id"], name: "index_list_attachments_on_list_id"
    t.index ["tag_id", "list_id"], name: "index_list_attachments_on_tag_id_and_list_id", unique: true
    t.index ["tag_id"], name: "index_list_attachments_on_tag_id"
  end

  create_table "list_memberships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "list_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["list_id"], name: "index_list_memberships_on_list_id"
    t.index ["user_id", "list_id"], name: "index_list_memberships_on_user_id_and_list_id", unique: true
    t.index ["user_id"], name: "index_list_memberships_on_user_id"
  end

  create_table "list_positions", force: :cascade do |t|
    t.integer "list_id"
    t.integer "user_id"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["list_id", "user_id"], name: "index_list_positions_on_list_id_and_user_id", unique: true
    t.index ["list_id"], name: "index_list_positions_on_list_id"
    t.index ["position", "user_id", "list_id"], name: "index_list_positions_on_position_and_user_id_and_list_id", unique: true
    t.index ["user_id"], name: "index_list_positions_on_user_id"
  end

  create_table "lists", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "project_id"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_lists_on_created_by_id"
    t.index ["project_id"], name: "index_lists_on_project_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_memberships_on_project_id"
    t.index ["user_id", "project_id"], name: "index_memberships_on_user_id_and_project_id", unique: true
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_projects_on_created_by_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.string "color"
    t.integer "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id", "name"], name: "index_tags_on_project_id_and_name", unique: true
    t.index ["project_id"], name: "index_tags_on_project_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.integer "current_project_id"
    t.index ["current_project_id"], name: "index_users_on_current_project_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

end
