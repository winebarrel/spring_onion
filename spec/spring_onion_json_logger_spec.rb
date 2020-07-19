# frozen_string_literal: true

RSpec.describe SpringOnion::JsonLogger do
  before do
    SpringOnion.color = false
    SpringOnion.logger = Logger.new('/dev/null')
  end

  let(:sql) do
    'SELECT `actor`.* FROM `actor`'
  end

  let(:explain) do
    [
      {
        'Extra' => nil,
        'filtered' => 100.0,
        'key' => nil,
        'key_len' => nil,
        'partitions' => nil,
        'possible_keys' => nil,
        'ref' => nil,
        'rows' => 11,
        'select_type' => 'SIMPLE',
        'table' => 'actor',
        'type' => 'ALL',
      },
    ]
  end

  let(:warnings) do
    {
      0 => [:slow_type],
    }
  end

  let(:trace) do
    [
      '/mnt/spec/spring_onion_spec.rb',
    ]
  end

  context 'compact' do
    specify 'log json' do
      log = nil

      SpringOnion.logger.formatter = lambda do |_, _, _, msg|
        log = msg
      end

      SpringOnion::JsonLogger.log(sql: sql, explain: explain, warnings: warnings, trace: trace)

      expect(log).to eq(
        '{' \
          '"sql":"SELECT `actor`.* FROM `actor`",' \
          '"explain":[{"line":1,"Extra":null,"filtered":100.0,"key":null,"key_len":null,"partitions":null,"possible_keys":null,"ref":null,"rows":11,"select_type":"SIMPLE","table":"actor","type":"ALL"}],' \
          '"warnings":{"line 1":["slow_type"]},' \
          '"backtrace":["/mnt/spec/spring_onion_spec.rb"]' \
        '}'
      )
    end
  end

  context 'pretty' do
    before do
      SpringOnion.json_pretty = true
    end

    specify 'log json' do
      log = nil

      SpringOnion.logger.formatter = lambda do |_, _, _, msg|
        log = msg
      end

      SpringOnion::JsonLogger.log(sql: sql, explain: explain, warnings: warnings, trace: trace)

      expect(log).to eq <<~JSON.strip
        {
          "sql": "SELECT `actor`.* FROM `actor`",
          "explain": [
            {
              "line": 1,
              "Extra": null,
              "filtered": 100.0,
              "key": null,
              "key_len": null,
              "partitions": null,
              "possible_keys": null,
              "ref": null,
              "rows": 11,
              "select_type": "SIMPLE",
              "table": "actor",
              "type": "ALL"
            }
          ],
          "warnings": {
            "line 1": [
              "slow_type"
            ]
          },
          "backtrace": [
            "/mnt/spec/spring_onion_spec.rb"
          ]
        }
      JSON
    end
  end
end
