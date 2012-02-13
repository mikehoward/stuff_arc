require 'active_record'

module StuffArc
  class Engine < Rails::Engine
    if Rails.version =~ /^3\./
      initializer "active_record.add_stuff_arc" do
        ActiveSupport.on_load(:active_record) do
          extend StuffArc::Base
        end
      end
    end
  end
end