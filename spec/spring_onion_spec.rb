# frozen_string_literal: true

RSpec.describe SpringOnion do
  before(:all) do
    ActiveRecord::Base.establish_connection(ENV.fetch('DATABASE_URL'))
    SpringOnion.enabled = true

    ENV.fetch('MYSQL_PING_ATTEMPTS', 1).to_i.times do
      SpringOnion.connection = ActiveRecord::Base.connection.raw_connection
      break if SpringOnion.connection.ping
    rescue Mysql2::Error::ConnectionError
      sleep 1
    end
  end

  context 'with explain' do
    before do
      SpringOnion.source_filter_re = %r{/spec/}
      SpringOnion.sql_filter_re = /actor/
      expect(SpringOnion.logger).to_not receive(:error)
    end

    specify 'no slow query' do
      expect(SpringOnion::JsonLogger).to_not receive(:log)
      Actor.where(actor_id: 1).to_a
    end

    specify 'slow query' do
      expect(SpringOnion::JsonLogger).to receive(:log) do |args|
        args.fetch(:trace).each { |t| t.sub!(%r{\A/.*/}, '').sub!(/:.*\z/, '') }
        args.fetch(:explain).fetch(0)['rows'] = 100

        expect(args).to eq(
          explain: [
            {
              'Extra' => nil,
              'filtered' => 100.0,
              'key' => nil,
              'key_len' => nil,
              'partitions' => nil,
              'possible_keys' => nil,
              'ref' => nil,
              'rows' => 100,
              'select_type' => 'SIMPLE',
              'table' => 'actor',
              'type' => 'ALL',
            },
          ],
          sql: 'SELECT `actor`.* FROM `actor`',
          trace: [
            'spring_onion_spec.rb',
          ],
          warnings: {
            0 => [:slow_type],
          }
        )
      end

      Actor.all.to_a
      City.all.to_a
    end

    specify 'no slow query with log_all' do
      SpringOnion.log_all = true

      expect(SpringOnion::JsonLogger).to receive(:log) do |args|
        args.fetch(:trace).each { |t| t.sub!(%r{\A/.*/}, '').sub!(/:.*\z/, '') }

        expect(args).to eq(
          explain: [
            {
              'Extra' => nil,
              'filtered' => 100.0,
              'key' => 'PRIMARY',
              'key_len' => '2',
              'partitions' => nil,
              'possible_keys' => 'PRIMARY',
              'ref' => 'const',
              'rows' => 1,
              'select_type' => 'SIMPLE',
              'table' => 'actor',
              'type' => 'const',
            },
          ],
          sql: 'SELECT `actor`.* FROM `actor` WHERE `actor`.`actor_id` = 1',
          trace: [
            'spring_onion_spec.rb',
          ],
          warnings: {}
        )
      end

      Actor.where(actor_id: 1).to_a
    end
  end

  context 'without explain' do
    before do
      SpringOnion.source_filter_re = %r{/$^/}
      expect(SpringOnion.logger).to_not receive(:error)
    end

    specify 'slow query' do
      expect(SpringOnion::JsonLogger).to_not receive(:log)
      Actor.all.to_a
    end
  end

  context 'with StandardError' do
    before do
      SpringOnion.source_filter_re = %r{/spec/}
      SpringOnion.sql_filter_re = /actor/
    end

    specify 'slow query' do
      allow(SpringOnion::JsonLogger).to receive(:log).and_raise('standard error')

      expect(SpringOnion.logger).to receive(:error).with(
        %r{standard error\n\t/.*:}
      )

      Actor.all.to_a
    end
  end
end
