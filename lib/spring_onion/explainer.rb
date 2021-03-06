# frozen_string_literal: true

module SpringOnion
  module Explainer
    def execute(*args)
      _with_explain(sql: args.first) do
        super
      end
    end

    private

    def _with_explain(sql:)
      begin
        if SpringOnion.enabled && sql =~ /\A\s*SELECT\b/i && SpringOnion.sql_filter.call(sql)
          trace = SpringOnion.source_filter.call(caller)

          unless trace.length.zero?
            conn = SpringOnion.connection || raw_connection
            exp = conn.query("EXPLAIN #{sql}", as: :hash).to_a
            exp.each { |r| r.delete('id') }
            _validate_explain(sql: sql, exp: exp, trace: trace)
          end
        end
      rescue StandardError => e
        SpringOnion.logger.error("#{e}\n\t#{e.backtrace.join("\n\t")}")
      end

      yield
    end

    def _validate_explain(sql:, exp:, trace:)
      warnings = SpringOnion.warnings
      warning_names_by_index = {}

      exp.each_with_index do |row, i|
        warning_names = warnings.select do |_name, validator|
          validator.call(row)
        end.keys

        warning_names_by_index[i] = warning_names unless warning_names.empty?
      end

      return if !SpringOnion.log_all && warning_names_by_index.empty?

      SpringOnion::JsonLogger.log(
        sql: sql,
        explain: exp,
        warnings: warning_names_by_index,
        trace: trace
      )
    end
  end
end
