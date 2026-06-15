# frozen_string_literal: true

module TraceOrigin
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/trace_origin.rake"
    end

    initializer "trace_origin.active_record" do
      ActiveSupport.on_load(:active_record) do
        extend TraceOrigin::DSL
      end
    end
  end
end
