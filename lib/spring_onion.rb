# frozen_string_literal: true

require 'logger'

require 'active_support'
require 'coderay'
require 'mysql2'

require 'spring_onion/config'
require 'spring_onion/error'
require 'spring_onion/explainer'
require 'spring_onion/json_logger'
require 'spring_onion/version'

ActiveSupport.on_load :active_record do
  if ENV['SPRING_ONION_DATABASE_URL'] && !SpringOnion.connection
    SpringOnion.connection = Mysql2::Client.new(
      ActiveRecord::ConnectionAdapters::ConnectionSpecification::ConnectionUrlResolver.new(url).to_hash
    )
  end

  require 'active_record/connection_adapters/abstract_mysql_adapter'
  ActiveRecord::ConnectionAdapters::AbstractMysqlAdapter.prepend SpringOnion::Explainer
end
