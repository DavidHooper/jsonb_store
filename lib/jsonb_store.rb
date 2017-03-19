require "jsonb_store/version"
require "active_record"
module JsonbStore
  extend ActiveSupport::Concern
  include Macro
end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.send(:include, JsonbAccessor)
end 
