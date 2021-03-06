# frozen_string_literal: true

module SpringOnion
  SLOW_SELECT_TYPE_RE = Regexp.union(
    'DEPENDENT UNION',
    'DEPENDENT SUBQUERY',
    'UNCACHEABLE UNION',
    'UNCACHEABLE SUBQUERY'
  )

  SLOW_TYPE_RE = Regexp.union('index', 'ALL')
  SLOW_POSSIBLE_KEYS_RE = Regexp.union('NULL')
  SLOW_KEY_RE = Regexp.union('NULL')

  SLOW_EXTRA_RE = Regexp.union(
    'Using filesort',
    'Using temporary'
  )

  @warnings = {
    slow_select_type: ->(exp) { SLOW_SELECT_TYPE_RE =~ exp['select_type'] },
    slow_type: ->(exp) { SLOW_TYPE_RE =~ exp['type'] },
    slow_possible_keys: ->(exp) { SLOW_POSSIBLE_KEYS_RE =~ exp['possible_keys'] },
    slow_key: ->(exp) { SLOW_KEY_RE =~ exp['key'] },
    slow_extra: ->(exp) { SLOW_EXTRA_RE =~ exp['Extra'] },
  }

  @enabled = (/\A(1|true)\z/i =~ ENV['SPRING_ONION_ENABLED'])

  @sql_filter_re = ENV['SPRING_ONION_SQL_FILTER_RE'].yield_self do |re|
    re ? Regexp.new(re, Regexp::IGNORECASE) : //
  end

  @ignore_sql_filter_re = Regexp.union(
    [/\binformation_schema\b/].tap do |ary|
      re = ENV['SPRING_ONION_IGNORE_SQL_FILTER_RE']
      ary << Regexp.new(re, Regexp::IGNORECASE) if re
    end
  )

  @sql_filter = lambda do |sql|
    @ignore_sql_filter_re !~ sql && @sql_filter_re =~ sql
  end

  @source_filter_re = ENV['SPRING_ONION_SOURCE_FILTER_RE'].yield_self do |re|
    re ? Regexp.new(re) : %r{/app/}
  end

  @ignore_source_filter_re = Regexp.union(
    [RbConfig::TOPDIR, *Gem.path, '/.rbenv/versions/'].tap do |ary|
      re = ENV['SPRING_ONION_IGNORE_SOURCE_FILTER_RE']
      ary << Regexp.new(re) if re
    end
  )

  @source_filter = lambda do |backtrace_lines|
    backtrace_lines = backtrace_lines.grep_v(@ignore_source_filter_re)
    idx = backtrace_lines.index { |l| @source_filter_re =~ l }
    idx ? backtrace_lines.slice(idx..-1) : []
  end

  @logger = Logger.new(ENV['SPRING_ONION_LOG'] || $stdout).tap do |logger|
    logger.formatter = lambda do |severity, datetime, _progname, msg|
      "\n#{self}\t#{severity}\t#{datetime}\t#{msg}\n"
    end
  end

  @log_all = (/\A(1|true)\z/i =~ ENV['SPRING_ONION_LOG_ALL'])
  @trace_len = 3
  @json_pretty = (/\A(1|true)\z/i =~ ENV['SPRING_ONION_JSON_PRETTY'])
  @color = /\A(1|true)\z/i =~ ENV.fetch('SPRING_ONION_COLOR', @logger.instance_variable_get(:@logdev)&.dev&.tty?&.to_s)

  class << self
    attr_accessor :enabled,
                  :connection,
                  :warnings,
                  :sql_filter_re, :ignore_sql_filter_re, :sql_filter,
                  :source_filter_re, :ignore_source_filter_re, :source_filter,
                  :logger,
                  :log_all,
                  :trace_len,
                  :json_pretty,
                  :color
  end
end
