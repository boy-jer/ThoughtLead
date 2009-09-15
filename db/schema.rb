# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090915164130) do

  create_table "access_class_relationships", :force => true do |t|
    t.integer "access_class_id", :null => false
    t.integer "child_id",        :null => false
  end

  create_table "access_classes", :force => true do |t|
    t.integer  "community_id", :null => false
    t.string   "name",         :null => false
    t.integer  "position",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
  end

  create_table "affiliate_actions", :force => true do |t|
    t.integer  "referrer_id"
    t.integer  "referred_id"
    t.string   "action"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "affiliate_actions", ["referrer_id", "action"], :name => "referrer_action"

  create_table "articles", :force => true do |t|
    t.integer  "community_id"
    t.integer  "content_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "attachments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "content_id"
    t.string   "content_type"
    t.string   "filename"
    t.integer  "size"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "embedded",     :default => false
    t.string   "panda_id"
  end

  create_table "avatars", :force => true do |t|
    t.integer  "user_id"
    t.string   "content_type"
    t.string   "filename"
    t.string   "thumbnail"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", :force => true do |t|
    t.integer  "community_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
  end

  create_table "categorizations", :id => false, :force => true do |t|
    t.integer "category_id"
    t.integer "article_id"
  end

  create_table "chapters", :force => true do |t|
    t.integer  "course_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "draft",      :default => true
    t.integer  "position"
  end

  create_table "communities", :force => true do |t|
    t.string   "host"
    t.integer  "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.boolean  "active",             :default => false
    t.string   "premium_link"
    t.string   "premium_text"
    t.string   "gateway_login"
    t.string   "gateway_password"
    t.string   "ga_property_id"
    t.boolean  "affiliates_enabled", :default => false
    t.string   "copyright"
  end

  create_table "content_access_classes", :force => true do |t|
    t.integer "content_id",      :null => false
    t.integer "access_class_id", :null => false
  end

  add_index "content_access_classes", ["content_id", "access_class_id"], :name => "index_content_access_classes_on_content_id_and_access_class_id", :unique => true

  create_table "contents", :force => true do |t|
    t.string   "title"
    t.text     "body",       :limit => 2147483647
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "draft",                            :default => true
    t.text     "teaser"
    t.boolean  "registered",                       :default => false
    t.string   "author",                           :default => ""
  end

  create_table "courses", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "user_id"
    t.integer  "community_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "draft",        :default => true
    t.integer  "position"
  end

  create_table "discussions", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "user_id"
    t.integer  "community_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "theme_id"
    t.datetime "thread_last_updated_at"
    t.integer  "responses_count"
  end

  create_table "email_subscriptions", :force => true do |t|
    t.integer "subscriber_id", :null => false
    t.integer "discussion_id", :null => false
  end

  create_table "emails", :force => true do |t|
    t.string   "subject"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lessons", :force => true do |t|
    t.integer  "content_id"
    t.integer  "chapter_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pages", :force => true do |t|
    t.integer  "community_id"
    t.string   "page_path"
    t.string   "name"
    t.string   "title"
    t.text     "body"
    t.boolean  "standalone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "system",       :default => false
    t.boolean  "active",       :default => true
  end

  add_index "pages", ["community_id", "page_path", "active"], :name => "active_pages", :unique => true

  create_table "responses", :force => true do |t|
    t.text     "body"
    t.integer  "user_id"
    t.integer  "discussion_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscription_payments", :force => true do |t|
    t.integer  "user_id",                                       :null => false
    t.string   "description",                                   :null => false
    t.decimal  "amount",         :precision => 10, :scale => 2, :null => false
    t.string   "transaction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscription_plans", :force => true do |t|
    t.string   "name",                                           :null => false
    t.decimal  "amount",          :precision => 10, :scale => 2, :null => false
    t.integer  "renewal_period",                                 :null => false
    t.string   "renewal_units",                                  :null => false
    t.integer  "trial_period",                                   :null => false
    t.string   "trial_units",                                    :null => false
    t.integer  "access_class_id",                                :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscriptions", :force => true do |t|
    t.integer  "user_id",                                             :null => false
    t.integer  "subscription_plan_id"
    t.decimal  "amount",               :precision => 10, :scale => 2, :null => false
    t.integer  "renewal_period",                                      :null => false
    t.string   "renewal_units",                                       :null => false
    t.integer  "access_class_id",                                     :null => false
    t.string   "state",                                               :null => false
    t.date     "next_renewal_at"
    t.string   "card_number"
    t.string   "card_expiration"
    t.string   "billing_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "theme_access_classes", :force => true do |t|
    t.integer "theme_id",        :null => false
    t.integer "access_class_id", :null => false
  end

  add_index "theme_access_classes", ["theme_id", "access_class_id"], :name => "index_theme_access_classes_on_theme_id_and_access_class_id", :unique => true

  create_table "themes", :force => true do |t|
    t.integer  "community_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.boolean  "registered",        :default => false
    t.integer  "position"
    t.integer  "discussions_count"
  end

  create_table "user_classes", :force => true do |t|
    t.integer "user_id"
    t.integer "access_class_id"
  end

  add_index "user_classes", ["user_id", "access_class_id"], :name => "index_user_classes_on_user_id_and_access_class_id", :unique => true

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "remember_token"
    t.string   "crypted_password"
    t.string   "salt"
    t.string   "reset_password_token"
    t.datetime "remember_token_expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "community_id"
    t.text     "about"
    t.text     "interests"
    t.string   "website_1"
    t.string   "website_2"
    t.string   "display_name"
    t.string   "location"
    t.string   "zipcode"
    t.text     "reason"
    t.boolean  "expert",                    :default => false
    t.boolean  "disabled",                  :default => false
    t.string   "first_name"
    t.string   "last_name"
    t.boolean  "super_admin",               :default => false
    t.integer  "access_class_id"
    t.boolean  "trial_available",           :default => true
    t.boolean  "send_email_notifications",  :default => false
    t.string   "affiliate_code"
    t.integer  "referred_by_id"
  end

  add_index "users", ["affiliate_code"], :name => "index_users_on_affiliate_code", :unique => true

end
