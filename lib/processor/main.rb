require "colorize"
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
      # Running processors in single separate thread.
      Parallel.each processors, :in_threads => 1 do |processor|
        processor.process content
      end

      warn "content #{'processed'.light_green}"

      count += 1
    end
  ensure
    processors.each(&:close)
  end

  stats = processors.map(&:get_stats)

  [stats, count]
end
