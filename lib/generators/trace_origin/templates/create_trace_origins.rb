class CreateTraceOrigins < ActiveRecord::Migration[<%= ActiveRecord::Migration.current_version %>]
  def change
    create_table :trace_origins do |t|
      t.string :record_type, null: false
      t.bigint :record_id, null: false
      t.text :trace, null: false

      t.timestamps
    end

    add_index :trace_origins, %i[record_type record_id]
    add_index :trace_origins, :created_at
  end
end
