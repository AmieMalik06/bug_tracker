ActiveRecord::Schema[7.2].define(version: 2026_03_24_144544) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activity_notification_activities", force: :cascade do |t|
    t.string "key"
    t.string "type"
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "notifiable_type"
    t.bigint "notifiable_id"
    t.string "target_type"
    t.bigint "target_id"
    t.boolean "read", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notifiable_type", "notifiable_id"], name: "index_activity_notification_activities_on_notifiable"
    t.index ["owner_type", "owner_id"], name: "index_activity_notification_activities_on_owner"
    t.index ["target_type", "target_id"], name: "index_activity_notification_activities_on_target"
  end

  create_table "activity_notification_targets", force: :cascade do |t|
    t.string "target_type"
    t.bigint "target_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["target_type", "target_id"], name: "index_activity_notification_targets_on_target"
  end

  create_table "assignments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_assignments_on_project_id"
    t.index ["user_id"], name: "index_assignments_on_user_id"
  end

  create_table "bugs", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "deadline"
    t.integer "bug_type"
    t.integer "status"
    t.bigint "project_id", null: false
    t.bigint "creator_id", null: false
    t.string "screenshot"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "assigned_user_id"
    t.index ["creator_id"], name: "index_bugs_on_creator_id"
    t.index ["project_id"], name: "index_bugs_on_project_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "recipient_type"
    t.bigint "recipient_id"
    t.string "key"
    t.jsonb "params"
    t.string "target_type"
    t.bigint "target_id"
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.index ["recipient_type", "recipient_id"], name: "index_notifications_on_recipient"
    t.index ["target_type", "target_id"], name: "index_notifications_on_target"
  end

  create_table "projects", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "assignments", "projects"                                                                                                                                                                                                                                                                                   
  add_foreign_key "assignments", "users"
  add_foreign_key "bugs", "projects"
  add_foreign_key "bugs", "users", column: "creator_id"
end
