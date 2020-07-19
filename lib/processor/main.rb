require_relative "../common/format"
require_relative "wrapper"
require_relative "params"

def get_processor_stats(pathes)
  params_combinations = get_processor_params_combinations

  processors = params_combinations.map do |params|
    Processor.new params[:type], params[:compression_level]
  end

  begin
    pathes.each.with_index do |path, index|
      content = File.open path, "rb", &:read

      percent   = format_percent index, pathes.length
      size_text = format_filesize content.bytesize

      warn "- #{percent}% processing path: #{path}, size: #{size_text}"

      processors.each { |processor| processor.process content }
    end
  ensure
    processors.each(&:close)
  end

  processors.map(&:get_stats)
end
