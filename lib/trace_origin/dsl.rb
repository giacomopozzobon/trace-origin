# frozen_string_literal: true

module TraceOrigin
  module DSL
    def trace_origin
      include TraceOrigin::Model
    end
  end
end