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
    end

    specify 'no slow query' do
      expect(SpringOnion::JsonLogger).to_not receive(:log)
      Actor.where(actor_id: 1).to_a
    end

    specify 'slow query' do
      expect(SpringOnion::JsonLogger).to receive(:log) do |args|
        args.fetch(:explain).tap do |exp|
          exp['rows'] = 100
        end

        args.fetch(:trace).each { |t| t.sub!(/:.*\z/, '') }

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
            '/mnt/spec/spring_onion_spec.rb',
          ],
          warnings: {
            0 => [:slow_type],
          }
        )
      end

      Actor.all.to_a
      City.all.to_a
    end

    specify 'no connection' do
      allow(SpringOnion).to receive(:connection).and_return(nil)

      expect do
        Actor.all.to_a
      end.to raise_error(SpringOnion::Error)
    end
  end

  context 'without explain' do
    before do
      SpringOnion.source_filter_re = %r{/$^/}
    end

    specify 'slow query' do
      expect(SpringOnion::JsonLogger).to_not receive(:log)
      Actor.all.to_a
    end
  end
end
