# frozen_string_literal: true

ActiveRecord::Schema[7.0].define(version: 20_260_611_000_001) do
  create_table "orders", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trace_origins", force: :cascade do |t|
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.text "trace", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_trace_origins_on_created_at"
    t.index %w[record_type record_id], name: "index_trace_origins_on_record_type_and_record_id"
  end
end
