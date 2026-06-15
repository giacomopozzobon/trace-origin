# frozen_string_literal: true

module TraceOrigin
  class Entry < ActiveRecord::Base
    self.table_name = "trace_origins"

    validates :record_type, :record_id, :trace, presence: true
  end
end
