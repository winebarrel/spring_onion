# frozen_string_literal: true

module SpringOnion
  module JsonLogger
    module_function

    def log(sql:, explain:, warnings:, trace:)
      h = {
        sql: sql,
        explain: explain.each_with_index.map { |r, i| { line: i + 1 }.merge(r) },
        warnings: warnings.transform_keys { |i| "line #{i + 1}" },
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
