require "colorize"

require_relative "params"
require_relative "wrapper"

def get_processor_stats(contents_provider, need_max_size: false)
  # Enumerator is lazy, we can calculate count and max size from first contents.
  is_first_contents = true
  count             = 0
  max_size          = 0

  stats = get_processor_params_combinations.map do |params|
    processor = Processor.new params[:type], params[:compression_level]

    begin
      warn \
        "processing contents, " \
        "type: #{params[:type]}, " \
        "compression level: #{params[:compression_level]}"

      contents_provider.call.each do |content|
        processor.process content
        warn "content #{'processed'.light_green}"

        if is_first_contents
          count += 1
          max_size = content.bytesize if need_max_size && max_size < content.bytesize
        end
      end

      is_first_contents = false
    ensure
      processor.close
    end

    processor.get_stats
  end

  [stats, count, max_size]
end
