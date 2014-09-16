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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130613043049) do

  create_table "csv_results", :force => true do |t|
    t.integer  "user_id",                         :null => false
    t.integer  "project_id"
    t.integer  "work_type_id",                    :null => false
    t.date     "result_date",                     :null => false
    t.text     "notes"
    t.boolean  "deleted",      :default => false, :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.datetime "start_at"
    t.datetime "end_at"
  end

  create_table "csv_sch_members", :force => true do |t|
    t.integer  "csv_schedule_id",                    :null => false
    t.integer  "user_id",                            :null => false
    t.boolean  "deleted",         :default => false, :null => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  create_table "csv_schedules", :force => true do |t|
    t.integer  "project_id",                       :null => false
    t.integer  "work_type_id"
    t.date     "schedule_date",                    :null => false
    t.datetime "start_at",                         :null => false
    t.datetime "end_at",                           :null => false
    t.integer  "auto_reflect",                     :null => false
    t.text     "notes"
    t.boolean  "deleted",       :default => false, :null => false
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  create_table "customers", :force => true do |t|
    t.string   "code",       :limit => 10
    t.string   "name",       :limit => 20, :null => false
    t.string   "name_ruby",  :limit => 40, :null => false
    t.integer  "pref_cd",                  :null => false
    t.text     "location"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "customers", ["code"], :name => "index_customers_on_code"

  create_table "databases", :force => true do |t|
    t.string   "name",       :limit => 20, :null => false
    t.integer  "view_order",               :null => false
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  create_table "deals", :force => true do |t|
    t.integer  "customer_id",                                                                         :null => false
    t.integer  "staff_user_id",                                                                       :null => false
    t.string   "solution_name",       :limit => 20
    t.string   "name",                :limit => 40,                                                   :null => false
    t.string   "customer_section",    :limit => 20
    t.string   "contact_person_name", :limit => 20
    t.decimal  "budge_amount",                      :precision => 10, :scale => 0, :default => 0,     :null => false
    t.decimal  "anticipated_price",                 :precision => 10, :scale => 0, :default => 0,     :null => false
    t.decimal  "order_volume",                      :precision => 10, :scale => 0, :default => 0,     :null => false
    t.string   "adoption_period",     :limit => 20
    t.string   "delivery_period",     :limit => 20
    t.string   "selection_method",    :limit => 20
    t.integer  "order_type_cd"
    t.string   "billing_destination", :limit => 40
    t.integer  "reliability_cd",                                                                      :null => false
    t.integer  "deal_status_cd"
    t.boolean  "prj_managed"
    t.text     "notes"
    t.boolean  "deleted",                                                          :default => false, :null => false
    t.datetime "created_at",                                                                          :null => false
    t.datetime "updated_at",                                                                          :null => false
  end

  create_table "development_languages", :force => true do |t|
    t.string   "name",       :limit => 20, :null => false
    t.integer  "view_order",               :null => false
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  create_table "expense_types", :force => true do |t|
    t.integer  "tax_division_id",               :null => false
    t.integer  "expense_item_cd",               :null => false
    t.string   "name",            :limit => 20, :null => false
    t.integer  "view_order",                    :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "expenses", :force => true do |t|
    t.integer  "user_id",                                                      :null => false
    t.integer  "project_id",                                                   :null => false
    t.integer  "expense_type_id",                                              :null => false
    t.integer  "tax_division_id",                                              :null => false
    t.date     "adjusted_date",                                                :null => false
    t.string   "item_name",       :limit => 40,                                :null => false
    t.decimal  "amount_paid",                   :precision => 10, :scale => 0, :null => false
    t.datetime "created_at",                                                   :null => false
    t.datetime "updated_at",                                                   :null => false
  end

  create_table "indirect_cost_ratios", :force => true do |t|
    t.integer  "indirect_cost_id",                                                        :null => false
    t.integer  "indirect_cost_subject_cd",                                                :null => false
    t.integer  "order_type_cd",                                                           :null => false
    t.decimal  "ratio",                    :precision => 5, :scale => 2, :default => 0.0, :null => false
    t.datetime "created_at",                                                              :null => false
    t.datetime "updated_at",                                                              :null => false
  end

  create_table "indirect_costs", :force => true do |t|
    t.date     "start_date",                             :null => false
    t.integer  "indirect_cost_method_cd", :default => 0, :null => false
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  create_table "messages", :force => true do |t|
    t.string   "title",      :limit => 50, :null => false
    t.text     "message",                  :null => false
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  create_table "notices", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "project_id", :null => false
    t.integer  "message_cd", :null => false
    t.text     "message"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "occupations", :force => true do |t|
    t.string   "name",       :limit => 20, :null => false
    t.integer  "view_order",               :null => false
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  create_table "operating_systems", :force => true do |t|
    t.string   "name",       :limit => 20, :null => false
    t.integer  "view_order",               :null => false
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  create_table "prj_databases", :force => true do |t|
    t.integer  "project_id",  :null => false
    t.integer  "database_id", :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "prj_databases", ["project_id", "database_id"], :name => "index_prj_databases_on_project_id_and_database_id", :unique => true

  create_table "prj_dev_languages", :force => true do |t|
    t.integer  "project_id",              :null => false
    t.integer  "development_language_id", :null => false
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "prj_dev_languages", ["project_id", "development_language_id"], :name => "idx_prj_dev_languages_on_project_id_and_development_language_id", :unique => true

  create_table "prj_expense_budgets", :force => true do |t|
    t.integer  "project_id",                                                    :null => false
    t.integer  "expense_item_cd",                                               :null => false
    t.decimal  "expense_budget",  :precision => 10, :scale => 0, :default => 0, :null => false
    t.datetime "created_at",                                                    :null => false
    t.datetime "updated_at",                                                    :null => false
  end

  add_index "prj_expense_budgets", ["project_id", "expense_item_cd"], :name => "index_prj_expense_budgets_on_project_id_and_expense_item_cd", :unique => true

  create_table "prj_members", :force => true do |t|
    t.integer  "project_id",                                                       :null => false
    t.integer  "user_id",                                                          :null => false
    t.decimal  "unit_price",       :precision => 10, :scale => 0, :default => 0,   :null => false
    t.decimal  "planned_man_days", :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.datetime "created_at",                                                       :null => false
    t.datetime "updated_at",                                                       :null => false
  end

  add_index "prj_members", ["project_id", "user_id"], :name => "index_prj_members_on_project_id_and_user_id", :unique => true

  create_table "prj_operating_systems", :force => true do |t|
    t.integer  "project_id",          :null => false
    t.integer  "operating_system_id", :null => false
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "prj_operating_systems", ["project_id", "operating_system_id"], :name => "idx_prj_operating_systems_on_project_id_and_operating_system_id", :unique => true

  create_table "prj_reflections", :force => true do |t|
    t.integer  "project_id",                                                                           :null => false
    t.decimal  "order_volume",                         :precision => 10, :scale => 0, :default => 0,   :null => false
    t.decimal  "sales_cost",                           :precision => 10, :scale => 0, :default => 0,   :null => false
    t.decimal  "man_day",                              :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.decimal  "direct_labor_cost",                    :precision => 10, :scale => 0, :default => 0,   :null => false
    t.decimal  "subcontract_cost",                     :precision => 10, :scale => 0, :default => 0,   :null => false
    t.decimal  "expense",                              :precision => 10, :scale => 0, :default => 0,   :null => false
    t.decimal  "indirect_labor_cost",                  :precision => 10, :scale => 0, :default => 0,   :null => false
    t.decimal  "development_cost",                     :precision => 10, :scale => 0, :default => 0,   :null => false
    t.decimal  "gross_profit",                         :precision => 10, :scale => 0, :default => 0,   :null => false
    t.decimal  "profit_ratio",                         :precision => 5,  :scale => 2, :default => 0.0, :null => false
    t.integer  "overall_rank",            :limit => 1,                                                 :null => false
    t.text     "reasons_for_termination"
    t.text     "self_evaluation"
    t.date     "finished_date",                                                                        :null => false
    t.date     "planned_finish_date",                                                                  :null => false
    t.integer  "delay_days",                                                                           :null => false
    t.integer  "schedule_rank",           :limit => 1,                                                 :null => false
    t.text     "reasons_for_dalay"
    t.decimal  "planned_man_days",                     :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.decimal  "exceeded_man_days",                    :precision => 6,  :scale => 2, :default => 0.0, :null => false
    t.integer  "man_days_rank",           :limit => 1,                                                 :null => false
    t.text     "reasons_for_overtime"
    t.decimal  "expense_budget",                       :precision => 10, :scale => 0, :default => 0,   :null => false
    t.decimal  "exceeded_expense",                     :precision => 10, :scale => 0, :default => 0,   :null => false
    t.integer  "expense_rank",            :limit => 1,                                                 :null => false
    t.text     "reasons_for_over_budget"
    t.text     "successful_things"
    t.text     "failed_things"
    t.text     "improvable_things"
    t.text     "next_actions"
    t.text     "learned_skills"
    t.datetime "created_at",                                                                           :null => false
    t.datetime "updated_at",                                                                           :null => false
  end

  create_table "prj_related_projects", :force => true do |t|
    t.integer  "project_id",         :null => false
    t.integer  "related_project_id", :null => false
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "prj_related_projects", ["project_id", "related_project_id"], :name => "index_prj_related_projects_on_project_id_and_related_project_id", :unique => true

  create_table "prj_sales_costs", :force => true do |t|
    t.integer  "project_id",                                                                  :null => false
    t.integer  "tax_division_id",                                                             :null => false
    t.string   "item_name",       :limit => 40,                                               :null => false
    t.decimal  "price",                         :precision => 10, :scale => 0, :default => 0, :null => false
    t.datetime "created_at",                                                                  :null => false
    t.datetime "updated_at",                                                                  :null => false
  end

  create_table "prj_work_types", :force => true do |t|
    t.integer  "project_id",                                                        :null => false
    t.integer  "work_type_id",                                                      :null => false
    t.decimal  "planned_man_days",   :precision => 6, :scale => 2, :default => 0.0, :null => false
    t.decimal  "presented_man_days", :precision => 6, :scale => 2, :default => 0.0, :null => false
    t.decimal  "progress_rate",      :precision => 5, :scale => 2, :default => 0.0, :null => false
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
  end

  add_index "prj_work_types", ["project_id", "work_type_id"], :name => "index_prj_work_types_on_project_id_and_work_type_id", :unique => true

  create_table "projects", :force => true do |t|
    t.integer  "customer_id"
    t.integer  "manager_id",                                                                    :null => false
    t.integer  "leader_id",                                                                     :null => false
    t.integer  "deal_id"
    t.integer  "order_type_cd",                                                                 :null => false
    t.integer  "status_cd",                                                                     :null => false
    t.string   "name",          :limit => 40,                                                   :null => false
    t.date     "start_date",                                                                    :null => false
    t.date     "started_date"
    t.date     "finish_date",                                                                   :null => false
    t.date     "finished_date"
    t.text     "remarks"
    t.boolean  "attention",                                                  :default => false, :null => false
    t.boolean  "deleted",                                                    :default => false, :null => false
    t.decimal  "order_volume",                :precision => 10, :scale => 0, :default => 0
    t.boolean  "locked",                                                     :default => false, :null => false
    t.string   "project_code",  :limit => 10,                                                   :null => false
    t.datetime "created_at",                                                                    :null => false
    t.datetime "updated_at",                                                                    :null => false
  end

  add_index "projects", ["project_code"], :name => "index_projects_on_project_code", :unique => true

  create_table "results", :force => true do |t|
    t.integer  "schedule_id"
    t.integer  "user_id",                         :null => false
    t.integer  "project_id"
    t.integer  "work_type_id",                    :null => false
    t.date     "result_date",                     :null => false
    t.text     "notes"
    t.boolean  "deleted",      :default => false, :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.datetime "start_at"
    t.datetime "end_at"
  end

  create_table "sales_reports", :force => true do |t|
    t.integer  "deal_id",                                             :null => false
    t.date     "activity_date",                                       :null => false
    t.integer  "activity_method",                                     :null => false
    t.string   "main_staff",         :limit => 20,                    :null => false
    t.text     "fellow_staff"
    t.string   "activity_objective", :limit => 40,                    :null => false
    t.string   "destination",        :limit => 40,                    :null => false
    t.text     "reports",                                             :null => false
    t.text     "responses"
    t.boolean  "deleted",                          :default => false, :null => false
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
  end

  create_table "sch_members", :force => true do |t|
    t.integer  "schedule_id",                    :null => false
    t.integer  "user_id",                        :null => false
    t.boolean  "deleted",     :default => false, :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "schedules", :force => true do |t|
    t.integer  "project_id",                       :null => false
    t.integer  "work_type_id"
    t.date     "schedule_date",                    :null => false
    t.datetime "start_at",                         :null => false
    t.datetime "end_at",                           :null => false
    t.integer  "auto_reflect",                     :null => false
    t.text     "notes"
    t.boolean  "deleted",       :default => false, :null => false
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  create_table "sections", :force => true do |t|
    t.string   "name",       :limit => 40,                    :null => false
    t.integer  "view_order",                                  :null => false
    t.boolean  "deleted",                  :default => false, :null => false
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  create_table "system_settings", :force => true do |t|
    t.integer  "notice_indication_days",                                    :default => 30,   :null => false
    t.decimal  "default_unit_price",         :precision => 10, :scale => 0, :default => 0,    :null => false
    t.boolean  "lock_project_after_editing",                                :default => true, :null => false
    t.datetime "created_at",                                                                  :null => false
    t.datetime "updated_at",                                                                  :null => false
  end

  create_table "tax_divisions", :force => true do |t|
    t.string   "name",        :limit => 20,                                                :null => false
    t.integer  "view_order",                                                               :null => false
    t.integer  "tax_type_cd",                                                              :null => false
    t.decimal  "tax_rate",                  :precision => 5, :scale => 2, :default => 0.0, :null => false
    t.datetime "created_at",                                                               :null => false
    t.datetime "updated_at",                                                               :null => false
  end

  create_table "unit_prices", :force => true do |t|
    t.integer  "user_id",                                                  :null => false
    t.date     "start_date",                                               :null => false
    t.decimal  "unit_price", :precision => 10, :scale => 0, :default => 0, :null => false
    t.datetime "created_at",                                               :null => false
    t.datetime "updated_at",                                               :null => false
  end

  create_table "users", :force => true do |t|
    t.integer  "section_id"
    t.integer  "occupation_id"
    t.string   "login",             :limit => 20,                    :null => false
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.integer  "login_count"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "official_position", :limit => 20
    t.string   "name",              :limit => 20,                    :null => false
    t.string   "name_ruby",         :limit => 40,                    :null => false
    t.integer  "user_rank_cd",                                       :null => false
    t.string   "home_phome_no",     :limit => 20
    t.string   "mobile_phone_no",   :limit => 20
    t.string   "mail_address1",     :limit => 40,                    :null => false
    t.string   "mail_address2",     :limit => 40
    t.string   "mail_address3",     :limit => 40
    t.boolean  "deleted",                         :default => false, :null => false
    t.string   "user_code",         :limit => 10,                    :null => false
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
  end

  create_table "work_types", :force => true do |t|
    t.string   "name",           :limit => 20,                    :null => false
    t.integer  "view_order",                                      :null => false
    t.boolean  "office_job",                   :default => false, :null => false
    t.string   "work_type_code", :limit => 10,                    :null => false
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
  end

  add_index "work_types", ["work_type_code"], :name => "index_work_types_on_work_type_code", :unique => true

end
