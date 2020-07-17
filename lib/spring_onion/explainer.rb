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
            _validate(exp, sql, trace)
          end
        end
      rescue StandardError => e
        SpringOnion.logger.error(e)
      end

      yield
    end

    def _validate(exp, sql, trace)
      violations = SpringOnion.violations
      violation_names_by_line = {}

      exp.each_with_index do |row, i|
        violation_names = violations.select do |_name, validator|
          validator.call(row)
        end.keys

        violation_names_by_line["line #{i + 1}"] = violation_names unless violation_names.empty?
      end

      return if violation_names_by_line.empty?

      h = {
        sql: sql,
        explain: exp.each_with_index.map { |r, i| { line: i + 1 }.merge(r) },
        violations: violation_names_by_line,
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
