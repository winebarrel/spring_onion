# SpringOnion

Log MySQL queries with EXPLAIN that may be slow.

Inspired by [MySQLCasualLog.pm](https://gist.github.com/kamipo/839e8a5b6d12bddba539).

[![Build Status](https://travis-ci.org/winebarrel/spring_onion.svg?branch=master)](https://travis-ci.org/winebarrel/spring_onion)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'spring_onion'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install spring_onion

## Usage

```ruby
#!/usr/bin/env ruby
require 'active_record'
require 'spring_onion'

ActiveRecord::Base.establish_connection(
  adapter:  'mysql2',
  username: 'root',
  database: 'employees'
)

SpringOnion.enabled = true # or `SPRING_ONION_ENABLED=1`
# `SPRING_ONION_DATABASE_URL=mysql2://...`
# default: SpringOnion.connection = ActiveRecord::Base.connection.raw_connection
SpringOnion.source_filter_re = //

class Employee < ActiveRecord::Base; end

p Employee.all.to_a.count
#=> SpringOnion	INFO	2020-07-18 01:53:27 +0900	{"sql":"SELECT `employees`.* FROM `employees`","explain":[{"line":1,"select_type":"SIMPLE","table":"employees","partitions":null,"type":"ALL","possible_keys":null,"key":null,"key_len":null,"ref":null,"rows":298936,"filtered":100.0,"Extra":null}],"warnings":{"line 1":["slow_type"]},"backtrace":["/foo/bar/zoo/baz.rb:18:in `\u003ctop (required)\u003e'"]}
#=> 300024
```

## Log Output

```json
{
    "sql": "SELECT `employees`.* FROM `employees`",
    "explain": [
        {
            "line": 1,
            "select_type": "SIMPLE",
            "table": "employees",
            "partitions": null,
            "type": "ALL",
            "possible_keys": null,
            "key": null,
            "key_len": null,
            "ref": null,
            "rows":298936,
            "filtered": 100.0,
            "Extra": null
        }
    ],
    "warnings": {
        "line 1": [
            "slow_type"
        ]
    },
    "backtrace": [
        "/foo/bar/zoo/baz.rb:18:in `\u003ctop (required)\u003e'"
    ]
}
```

## Test

```sh
docker-compose build
docker-compose run client bundle exec appraisal ar60 rake
```
