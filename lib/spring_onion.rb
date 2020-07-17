# frozen_string_literal: true

require 'logger'
require 'coderay'
require 'active_support'

require 'spring_onion/config'
require 'spring_onion/error'
require 'spring_onion/explainer'
require 'spring_onion/version'

ActiveSupport.on_load :active_record do
  require 'active_record/connection_adapters/abstract_mysql_adapter'
  ActiveRecord::ConnectionAdapters::AbstractMysqlAdapter.prepend SpringOnion::Explainer
end
