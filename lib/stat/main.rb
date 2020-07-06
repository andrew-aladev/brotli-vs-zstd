# require_relative "../common/format"
# require_relative "processor"

# def process_files(file_pathes, &_block)
#   stats = []
#
#   file_pathes.each.with_index do |path, index|
#     content = File.read path
#
#     percent   = format_percent index, file_pathes.length
#     size_text = format_filesize content.bytesize
#
#     warn "- #{percent}% processing script, path: #{path}, size: #{size_text}"
#
#     compressor_options_combinations.each { |compressor_options| stats << yield(content, compressor_options) }
#   end
#
#   stats
# end
