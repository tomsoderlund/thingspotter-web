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

ActiveRecord::Schema.define(:version => 20110925185620) do

  create_table "brands", :force => true do |t|
    t.string   "name",         :limit => 64
    t.string   "website",      :limit => 64
    t.string   "search_url",   :limit => 128
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "things_count",                :default => 0
  end

  create_table "collection_things", :force => true do |t|
    t.integer  "collection_id"
    t.integer  "thing_id"
    t.integer  "position",      :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "collections", :force => true do |t|
    t.string   "name",                    :limit => 64
    t.text     "description"
    t.integer  "user_id"
    t.integer  "collection_things_count",               :default => 0
    t.boolean  "is_featured",                           :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "thing_id"
    t.integer  "spot_id"
    t.string   "comment",    :limit => 140
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "countries", :force => true do |t|
    t.string "name",         :limit => 40
    t.string "country_code", :limit => 2
  end

  create_table "followers", :force => true do |t|
    t.integer  "follower_id"
    t.integer  "follows_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friends", :force => true do |t|
    t.integer  "user_id"
    t.integer  "friend_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invitations", :force => true do |t|
    t.integer  "sender_id"
    t.string   "recipient_email"
    t.string   "token"
    t.datetime "sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "languages", :force => true do |t|
    t.string "name",          :limit => 10
    t.string "language_code", :limit => 2
  end

  create_table "pages", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.string   "permalink"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spots", :force => true do |t|
    t.integer  "user_id"
    t.integer  "thing_id"
    t.integer  "store_id"
    t.string   "website_url",            :limit => 256
    t.float    "price"
    t.integer  "currency_id"
    t.boolean  "is_wanted",                             :default => false
    t.boolean  "is_owned",                              :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "recommended_to_user_id"
    t.integer  "original_spot_id"
    t.boolean  "is_website_store",                      :default => false
    t.boolean  "is_website_productpage",                :default => false
  end

  create_table "stores", :force => true do |t|
    t.string   "name",        :limit => 64
    t.string   "url_key",     :limit => 128
    t.string   "url_data",    :limit => 128
    t.string   "body_data",   :limit => 256
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "spots_count",                :default => 0
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type", :limit => 10
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string  "name",            :limit => 20
    t.boolean "show_by_default",               :default => false
  end

  create_table "things", :force => true do |t|
    t.integer  "user_id"
    t.string   "name",               :limit => 64
    t.text     "description"
    t.integer  "brand_id"
    t.string   "barcode",            :limit => 16
    t.string   "photo_file_name",    :limit => 128
    t.string   "photo_content_type", :limit => 16
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo_remote_url"
    t.integer  "spots_count",                       :default => 0
    t.boolean  "is_featured",                       :default => false
  end

  create_table "users", :force => true do |t|
    t.string   "name",                :limit => 100
    t.integer  "fb_user_id"
    t.string   "fb_session_key",      :limit => 150
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",               :limit => 100
    t.date     "born_at"
    t.integer  "gender_id"
    t.integer  "country_id"
    t.integer  "language_id"
    t.integer  "timezone_id"
    t.integer  "currency_id"
    t.boolean  "is_admin",                           :default => false
    t.integer  "points",                             :default => 0
    t.integer  "status_level_id",                    :default => 1
    t.boolean  "post_to_facebook",                   :default => true
    t.boolean  "post_to_twitter",                    :default => true
    t.boolean  "email_newsletter",                   :default => true
    t.boolean  "email_notifications",                :default => true
    t.integer  "spots_count",                        :default => 0
    t.integer  "invitation_id"
    t.integer  "invitation_limit",                   :default => 0
    t.string   "fb_access_token",     :limit => 100
  end

end
