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

ActiveRecord::Schema[8.1].define(version: 2026_10_09_150105) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "account_users", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "account_id", null: false
    t.bigint "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_account_users_on_account_id"
    t.index ["role_id"], name: "index_account_users_on_role_id"
    t.index ["user_id"], name: "index_account_users_on_user_id"
  end

  create_table "accounts", force: :cascade do |t|
    t.string "name"
    t.string "address1"
    t.string "address2"
    t.string "zip"
    t.string "city"
    t.string "country_code"
    t.string "province_code"
    t.string "billing_contact"
    t.integer "status", default: 0, null: false
    t.string "uuid"
    t.string "plan", default: "free", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_accounts_on_status"
  end

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "coupons", force: :cascade do |t|
    t.string "name"
    t.date "valid_at"
    t.date "valid_until"
    t.string "uuid"
    t.integer "amount_off"
    t.decimal "percent_off"
    t.boolean "duration_limited", default: true
    t.integer "duration_in_month", default: 1
    t.integer "redeem_limit", default: 1
    t.integer "status", default: 0, null: false
    t.string "stripe_id"
    t.string "plan_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "email_changes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "from"
    t.string "to"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_email_changes_on_user_id"
  end

  create_table "environments", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.string "name"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_environments_on_organization_id"
  end

  create_table "environments_projects", id: false, force: :cascade do |t|
    t.bigint "project_id", null: false
    t.bigint "environment_id", null: false
    t.index ["environment_id", "project_id"], name: "index_environments_projects_on_environment_id_and_project_id"
    t.index ["project_id", "environment_id"], name: "index_environments_projects_on_project_id_and_environment_id"
  end

  create_table "instance_credits", force: :cascade do |t|
    t.date "day"
    t.integer "credits"
    t.string "service_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["day"], name: "index_instance_credits_on_day"
    t.index ["service_name", "day"], name: "index_instance_credits_on_service_name_and_day", unique: true
    t.index ["service_name"], name: "index_instance_credits_on_service_name"
  end

  create_table "inventory_instance_attrs", force: :cascade do |t|
    t.bigint "model_category_attr_id", null: false
    t.bigint "instance_id", null: false
    t.string "name"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["instance_id"], name: "index_inventory_instance_attrs_on_instance_id"
    t.index ["model_category_attr_id"], name: "index_inventory_instance_attrs_on_model_category_attr_id"
  end

  create_table "inventory_instances", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.bigint "environment_id", null: false
    t.bigint "model_category_id", null: false
    t.string "name"
    t.string "uuid"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["environment_id"], name: "index_inventory_instances_on_environment_id"
    t.index ["model_category_id"], name: "index_inventory_instances_on_model_category_id"
    t.index ["workspace_id"], name: "index_inventory_instances_on_workspace_id"
  end

  create_table "inventory_model_categories", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "model_family_id", null: false
    t.string "name"
    t.string "resource_type"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["model_family_id"], name: "index_inventory_model_categories_on_model_family_id"
    t.index ["organization_id"], name: "index_inventory_model_categories_on_organization_id"
  end

  create_table "inventory_model_category_attrs", force: :cascade do |t|
    t.bigint "model_category_id", null: false
    t.string "name"
    t.string "attr_name"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["model_category_id"], name: "index_inventory_model_category_attrs_on_model_category_id"
  end

  create_table "inventory_model_families", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_inventory_model_families_on_organization_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.bigint "subscription_id", null: false
    t.decimal "amount", precision: 10, scale: 2
    t.date "date"
    t.date "period_end"
    t.date "period_start"
    t.string "stripe_invoice_id"
    t.string "status"
    t.string "ref"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subscription_id"], name: "index_invoices_on_subscription_id"
  end

  create_table "key_value_stores", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.bigint "environment_id", null: false
    t.string "key"
    t.text "value"
    t.boolean "one_time_only", default: false
    t.boolean "private", default: false
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["environment_id"], name: "index_key_value_stores_on_environment_id"
    t.index ["expires_at"], name: "index_key_value_stores_on_expires_at"
    t.index ["key"], name: "index_key_value_stores_on_key"
    t.index ["workspace_id"], name: "index_key_value_stores_on_workspace_id"
  end

  create_table "license_add_ons", force: :cascade do |t|
    t.bigint "instance_id", null: false
    t.string "name"
    t.string "uuid"
    t.text "description"
    t.boolean "active", default: true
    t.decimal "unit_cost", precision: 10, scale: 4
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["instance_id"], name: "index_license_add_ons_on_instance_id"
  end

  create_table "license_applications", force: :cascade do |t|
    t.string "name"
    t.string "short_name"
    t.string "owner"
    t.date "renewal_date"
    t.text "data"
    t.string "vendor"
    t.string "tier"
    t.string "uuid"
    t.integer "seats"
    t.integer "licencess_allowed"
    t.decimal "unit_cost", precision: 10, scale: 2
    t.integer "status", default: 0, null: false
    t.integer "alert_renewal_2", default: 30
    t.integer "alert_renewal_1", default: 90
    t.decimal "alert_seats_2", precision: 10, scale: 2, default: "0.95"
    t.decimal "alert_seats_1", precision: 10, scale: 2, default: "0.85"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "account_id"
    t.index ["account_id"], name: "index_license_applications_on_account_id"
  end

  create_table "license_instances", force: :cascade do |t|
    t.bigint "application_id", null: false
    t.string "name"
    t.string "uuid"
    t.string "short_name"
    t.string "owner"
    t.date "renewal_date"
    t.integer "licencess_allowed"
    t.text "data"
    t.integer "seats"
    t.decimal "unit_cost", precision: 10, scale: 2
    t.integer "status", default: 0, null: false
    t.integer "alert_renewal_2", default: 30
    t.integer "alert_renewal_1", default: 90
    t.decimal "alert_seats_2", precision: 10, scale: 2, default: "0.95"
    t.decimal "alert_seats_1", precision: 10, scale: 2, default: "0.85"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "tier"
    t.index ["application_id"], name: "index_license_instances_on_application_id"
    t.index ["uuid", "application_id"], name: "index_license_instances_on_uuid_and_application_id", unique: true
  end

  create_table "license_licensees", force: :cascade do |t|
    t.bigint "instance_id", null: false
    t.string "uuid", null: false
    t.integer "status", default: 0, null: false
    t.string "revision"
    t.date "last_access"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["instance_id"], name: "index_license_licensees_on_instance_id"
  end

  create_table "license_providers", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "name"
    t.string "uuid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_license_providers_on_account_id"
  end

  create_table "license_quote_add_ons", force: :cascade do |t|
    t.bigint "add_on_id", null: false
    t.bigint "quote_instance_id", null: false
    t.decimal "amount", precision: 10, scale: 2
    t.integer "seats"
    t.boolean "unused", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["add_on_id"], name: "index_license_quote_add_ons_on_add_on_id"
    t.index ["quote_instance_id"], name: "index_license_quote_add_ons_on_quote_instance_id"
  end

  create_table "license_quote_applications", force: :cascade do |t|
    t.bigint "application_id", null: false
    t.bigint "quote_id", null: false
    t.decimal "amount", precision: 10, scale: 2
    t.integer "seats"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["application_id"], name: "index_license_quote_applications_on_application_id"
    t.index ["quote_id"], name: "index_license_quote_applications_on_quote_id"
  end

  create_table "license_quote_instances", force: :cascade do |t|
    t.bigint "instance_id", null: false
    t.bigint "quote_application_id", null: false
    t.decimal "amount", precision: 10, scale: 2
    t.integer "seats"
    t.boolean "unused", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["instance_id"], name: "index_license_quote_instances_on_instance_id"
    t.index ["quote_application_id"], name: "index_license_quote_instances_on_quote_application_id"
  end

  create_table "license_quotes", force: :cascade do |t|
    t.bigint "application_id", null: false
    t.bigint "provider_id", null: false
    t.string "uuid"
    t.date "available_on"
    t.date "available_until"
    t.date "approved_at"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["application_id"], name: "index_license_quotes_on_application_id"
    t.index ["provider_id"], name: "index_license_quotes_on_provider_id"
  end

  create_table "license_team_members", force: :cascade do |t|
    t.string "uuid", null: false
    t.bigint "manager_id"
    t.string "role"
    t.string "revision"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "account_id"
    t.index ["account_id"], name: "index_license_team_members_on_account_id"
    t.index ["manager_id"], name: "index_license_team_members_on_manager_id"
  end

  create_table "license_uploads", force: :cascade do |t|
    t.bigint "instance_id", null: false
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["instance_id"], name: "index_license_uploads_on_instance_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "recipient_type", null: false
    t.bigint "recipient_id", null: false
    t.string "title"
    t.string "message"
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipient_type", "recipient_id"], name: "index_notifications_on_recipient"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.string "uuid"
    t.text "description"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "account_id", null: false
    t.index ["account_id"], name: "index_organizations_on_account_id"
    t.index ["status"], name: "index_organizations_on_status"
    t.index ["uuid"], name: "index_organizations_on_uuid"
  end

  create_table "processed_dates", force: :cascade do |t|
    t.date "day"
    t.datetime "start_at"
    t.datetime "end_at"
    t.boolean "pushed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["day"], name: "index_processed_dates_on_day"
  end

  create_table "projects", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.string "name"
    t.string "uuid"
    t.text "description"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_projects_on_organization_id"
    t.index ["status"], name: "index_projects_on_status"
    t.index ["uuid"], name: "index_projects_on_uuid"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "statefile_locks", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.datetime "locked_at"
    t.string "uuid"
    t.string "operation"
    t.string "info"
    t.string "who"
    t.string "version"
    t.string "path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["workspace_id"], name: "index_statefile_locks_on_workspace_id"
  end

  create_table "statefile_tags", force: :cascade do |t|
    t.bigint "statefile_id", null: false
    t.string "tag"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["statefile_id"], name: "index_statefile_tags_on_statefile_id"
  end

  create_table "statefiles", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.bigint "environment_id", null: false
    t.string "uuid"
    t.text "content", default: ""
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["environment_id"], name: "index_statefiles_on_environment_id"
    t.index ["uuid"], name: "index_statefiles_on_uuid"
    t.index ["workspace_id"], name: "index_statefiles_on_workspace_id"
  end

  create_table "subscription_coupons", force: :cascade do |t|
    t.bigint "subscription_id", null: false
    t.bigint "coupon_id", null: false
    t.date "used"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["coupon_id"], name: "index_subscription_coupons_on_coupon_id"
    t.index ["subscription_id"], name: "index_subscription_coupons_on_subscription_id"
  end

  create_table "subscription_credits", force: :cascade do |t|
    t.bigint "subscription_id", null: false
    t.string "uuid"
    t.date "month"
    t.integer "credits"
    t.integer "credit_balance"
    t.string "event"
    t.integer "order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subscription_id"], name: "index_subscription_credits_on_subscription_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "stripe_customer_id"
    t.string "plan_id"
    t.datetime "current_period_end", default: -> { "(now() + 'P1M'::interval)" }, null: false
    t.datetime "current_period_start", default: -> { "now()" }
    t.boolean "active", default: true
    t.boolean "yearly", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_subscriptions_on_account_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.bigint "tag_id", null: false
    t.string "taggable_type", null: false
    t.bigint "taggable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable"
  end

  create_table "tags", force: :cascade do |t|
    t.string "key"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "team_roles", force: :cascade do |t|
    t.bigint "team_id", null: false
    t.string "resource_type", null: false
    t.bigint "resource_id", null: false
    t.integer "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["resource_type", "resource_id"], name: "index_team_roles_on_resource"
    t.index ["team_id"], name: "index_team_roles_on_team_id"
  end

  create_table "team_users", force: :cascade do |t|
    t.bigint "team_id", null: false
    t.bigint "user_id", null: false
    t.integer "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_team_users_on_team_id"
    t.index ["user_id"], name: "index_team_users_on_user_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.string "uuid"
    t.string "description"
    t.integer "source", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "account_id", null: false
    t.index ["account_id"], name: "index_teams_on_account_id"
  end

  create_table "tests", force: :cascade do |t|
    t.string "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tokens", force: :cascade do |t|
    t.string "name"
    t.string "scopable_type", null: false
    t.bigint "scopable_id", null: false
    t.bigint "environment_id"
    t.datetime "expiration"
    t.datetime "last_used_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.index ["environment_id"], name: "index_tokens_on_environment_id"
    t.index ["scopable_type", "scopable_id"], name: "index_tokens_on_scopable"
    t.index ["type"], name: "index_tokens_on_type"
  end

  create_table "trust_assets", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.bigint "environment_id", null: false
    t.string "name"
    t.datetime "expires_at"
    t.string "issuer"
    t.integer "format"
    t.string "consumer"
    t.text "description"
    t.integer "reminder_days", default: 7
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["environment_id"], name: "index_trust_assets_on_environment_id"
    t.index ["workspace_id"], name: "index_trust_assets_on_workspace_id"
  end

  create_table "usage_daily_accounts", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.date "day"
    t.integer "units"
    t.integer "credits"
    t.string "service_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_usage_daily_accounts_on_account_id"
    t.index ["day"], name: "index_usage_daily_accounts_on_day"
    t.index ["service_name", "day", "account_id"], name: "idx_on_service_name_day_account_id_0afce22fe2", unique: true
    t.index ["service_name"], name: "index_usage_daily_accounts_on_service_name"
  end

  create_table "usage_daily_organizations", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.date "day"
    t.integer "units"
    t.integer "credits"
    t.string "service_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["day"], name: "index_usage_daily_organizations_on_day"
    t.index ["organization_id"], name: "index_usage_daily_organizations_on_organization_id"
    t.index ["service_name", "day", "organization_id"], name: "idx_on_service_name_day_organization_id_e7f766aeb2", unique: true
    t.index ["service_name"], name: "index_usage_daily_organizations_on_service_name"
  end

  create_table "usage_daily_projects", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.date "day"
    t.integer "units"
    t.integer "credits"
    t.string "service_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["day"], name: "index_usage_daily_projects_on_day"
    t.index ["project_id"], name: "index_usage_daily_projects_on_project_id"
    t.index ["service_name", "day", "project_id"], name: "idx_on_service_name_day_project_id_00dcb4d4fa", unique: true
    t.index ["service_name"], name: "index_usage_daily_projects_on_service_name"
  end

  create_table "usage_daily_workspaces", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.date "day"
    t.integer "units"
    t.integer "credits"
    t.string "service_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["day"], name: "index_usage_daily_workspaces_on_day"
    t.index ["service_name", "day", "workspace_id"], name: "idx_on_service_name_day_workspace_id_4651177e64", unique: true
    t.index ["service_name"], name: "index_usage_daily_workspaces_on_service_name"
    t.index ["workspace_id"], name: "index_usage_daily_workspaces_on_workspace_id"
  end

  create_table "usage_monthly_accounts", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.date "month"
    t.integer "units"
    t.integer "credits"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_usage_monthly_accounts_on_account_id"
    t.index ["month", "account_id"], name: "index_usage_monthly_accounts_on_month_and_account_id", unique: true
    t.index ["month"], name: "index_usage_monthly_accounts_on_month"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.boolean "email_verified", default: false
    t.string "prefered_language", default: "en"
    t.integer "global_role", default: 254
    t.string "uid"
    t.string "provider"
    t.string "name"
    t.string "image"
    t.boolean "password_change_required", default: false
    t.datetime "last_access_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  create_table "workspace_environments", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.bigint "environment_id", null: false
    t.integer "resources", default: 0
    t.integer "lines", default: 0
    t.integer "size", default: 0
    t.decimal "cost", precision: 10, scale: 6, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["environment_id"], name: "index_workspace_environments_on_environment_id"
    t.index ["workspace_id"], name: "index_workspace_environments_on_workspace_id"
  end

  create_table "workspaces", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.string "name"
    t.string "uuid"
    t.text "description"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_workspaces_on_project_id"
    t.index ["status"], name: "index_workspaces_on_status"
    t.index ["uuid"], name: "index_workspaces_on_uuid"
  end

  add_foreign_key "account_users", "accounts"
  add_foreign_key "account_users", "roles"
  add_foreign_key "account_users", "users"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "email_changes", "users"
  add_foreign_key "environments", "organizations"
  add_foreign_key "inventory_instance_attrs", "inventory_instances", column: "instance_id"
  add_foreign_key "inventory_instance_attrs", "inventory_model_category_attrs", column: "model_category_attr_id"
  add_foreign_key "inventory_instances", "environments"
  add_foreign_key "inventory_instances", "inventory_model_categories", column: "model_category_id"
  add_foreign_key "inventory_instances", "workspaces"
  add_foreign_key "inventory_model_categories", "inventory_model_families", column: "model_family_id"
  add_foreign_key "inventory_model_categories", "organizations"
  add_foreign_key "inventory_model_category_attrs", "inventory_model_categories", column: "model_category_id"
  add_foreign_key "inventory_model_families", "organizations"
  add_foreign_key "invoices", "subscriptions"
  add_foreign_key "key_value_stores", "environments"
  add_foreign_key "key_value_stores", "workspaces"
  add_foreign_key "license_add_ons", "license_instances", column: "instance_id"
  add_foreign_key "license_applications", "accounts"
  add_foreign_key "license_instances", "license_applications", column: "application_id"
  add_foreign_key "license_licensees", "license_instances", column: "instance_id"
  add_foreign_key "license_providers", "accounts"
  add_foreign_key "license_quote_add_ons", "license_add_ons", column: "add_on_id"
  add_foreign_key "license_quote_add_ons", "license_quote_instances", column: "quote_instance_id"
  add_foreign_key "license_quote_applications", "license_applications", column: "application_id"
  add_foreign_key "license_quote_applications", "license_quotes", column: "quote_id"
  add_foreign_key "license_quote_instances", "license_instances", column: "instance_id"
  add_foreign_key "license_quote_instances", "license_quote_applications", column: "quote_application_id"
  add_foreign_key "license_quotes", "license_applications", column: "application_id"
  add_foreign_key "license_quotes", "license_providers", column: "provider_id"
  add_foreign_key "license_team_members", "accounts"
  add_foreign_key "license_team_members", "license_team_members", column: "manager_id"
  add_foreign_key "license_uploads", "license_instances", column: "instance_id"
  add_foreign_key "organizations", "accounts"
  add_foreign_key "projects", "organizations"
  add_foreign_key "sessions", "users"
  add_foreign_key "statefile_locks", "workspaces"
  add_foreign_key "statefile_tags", "statefiles"
  add_foreign_key "statefiles", "environments"
  add_foreign_key "statefiles", "workspaces"
  add_foreign_key "subscription_coupons", "coupons"
  add_foreign_key "subscription_coupons", "subscriptions"
  add_foreign_key "subscription_credits", "subscriptions"
  add_foreign_key "subscriptions", "accounts"
  add_foreign_key "taggings", "tags"
  add_foreign_key "team_roles", "teams"
  add_foreign_key "team_users", "teams"
  add_foreign_key "team_users", "users"
  add_foreign_key "teams", "accounts"
  add_foreign_key "tokens", "environments"
  add_foreign_key "trust_assets", "environments"
  add_foreign_key "trust_assets", "workspaces"
  add_foreign_key "usage_daily_accounts", "accounts"
  add_foreign_key "usage_daily_organizations", "organizations"
  add_foreign_key "usage_daily_projects", "projects"
  add_foreign_key "usage_daily_workspaces", "workspaces"
  add_foreign_key "usage_monthly_accounts", "accounts"
  add_foreign_key "workspace_environments", "environments"
  add_foreign_key "workspace_environments", "workspaces"
  add_foreign_key "workspaces", "projects"
end
