# frozen_string_literal: true

module SpringOnion
  module Explainer
    def execute(*args)
      _with_explain(args.first) do
        super
      end
    end

    def _with_explain(sql)
      begin
        if SpringOnion.enabled && sql =~ /^SELECT\b/ && SpringOnion.sql_filter.call(sql)
          trace = SpringOnion.source_filter.call(caller)

          unless trace.length.zero?
            conn = SpringOnion.connection
            raise SpringOnion::Error, 'MySQL connection is not set' unless conn

            exp = conn.query("EXPLAIN #{sql}", as: :hash).to_a
            exp.each { |r| r.delete('id') }
            _validate_explain(exp, sql, trace)
          end
        end
      rescue StandardError => e
        SpringOnion.logger.error(e)
      end

      yield
    end

    def _validate_explain(exp, sql, trace)
      warnings = SpringOnion.warnings
      warning_names_by_line = {}

      exp.each_with_index do |row, i|
        warning_names = warnings.select do |_name, validator|
          validator.call(row)
        end.keys

        warning_names_by_line["line #{i + 1}"] = warning_names unless warning_names.empty?
      end

      return if warning_names_by_line.empty?

      h = {
        sql: sql,
        explain: exp.each_with_index.map { |r, i| { line: i + 1 }.merge(r) },
        warnings: warning_names_by_line,
        backtrace: trace.slice(0, SpringOnion.trace_len),
      }

      line = if SpringOnion.json_pretty
               JSON.pretty_generate(h)
             else
               JSON.dump(h)
             end

      line = CodeRay.scan(line, :json).terminal if SpringOnion.color
      SpringOnion.logger.info(line)
    end
  end
end
