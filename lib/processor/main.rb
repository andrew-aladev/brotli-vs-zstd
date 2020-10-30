require "parallel"

require_relative "params"
require_relative "wrapper"

def get_processor_stats(contents)
  processors = get_processor_params_combinations.map do |params|
    Processor.new params[:type], params[:compression_level]
  end

  count = 0

  begin
    contents.each do |content|
      Parallel.each(processors) do |processor|
        processor.process content
      end

      count += 1
    end
  ensure
    processors.each(&:close)
  end

  stats = processors.map(&:get_stats)

  [stats, count]
end
