require_relative "colorize"
require_relative "format"
require_relative "time"

def get_file_path_stats(file_pathes, compress_block, decompress_block)
  total_content_size            = 0
  total_compressed_content_size = 0
  total_compressed_time         = 0
  total_decompressed_time       = 0

  file_pathes.map.with_index do |path, index|
    percent   = format_percent index, file_pathes.length
    content   = File.read path
    size_text = format_filesize content.bytesize

    warn "- #{percent}% processing script, path: #{path}, size: #{size_text}"

    compressed_content,   compressed_time   = with_time { compress_block.call content }
    decompressed_content, decompressed_time = with_time { decompress_block.call compressed_content }

    raise "decompressed content does not equal to original content" unless decompressed_content == content

    total_content_size            += content.bytesize
    total_compressed_content_size += compressed_content.bytesize
    total_compressed_time         += compressed_time
    total_decompressed_time       += decompressed_time
  end
end

# def get_script_stats(pathes, compress_block, decompress_block)
#     ratio = content.length.to_f / compressed_content.length
#
#     ratio_text             = format_float(ratio).light_green
#     compressed_time_text   = format_float compressed_time
#     decompressed_time_text = format_float decompressed_time
#
#     warn "ratio: #{ratio_text}, " \
#       "compressed time: #{compressed_time_text}, " \
#       "decompressed time: #{decompressed_time_text}"
#
#     {
#       :ratio             => ratio,
#       :compressed_time   => compressed_time,
#       :decompressed_time => decompressed_time
#     }
# end

# MAX_COMPRESSOR_PORTION_LENGTH   = 1 << 21 # 2 MB
# MAX_DECOMPRESSOR_PORTION_LENGTH = 1 << 23 # 8 MB

# def open_pipe_with_processor(create_processor_block, mode, &_block)
#   read_io, write_io = IO.pipe
#
#   main_io = mode == :writer ? write_io : read_io
#
#   begin
#     processor = create_processor_block.call main_io
#
#     begin
#       yield processor, read_io, write_io
#     ensure
#       processor.close
#     end
#   ensure
#     write_io.close
#     read_io.close
#   end
# end

# def get_all_scripts_stat(pathes, create_compressor_block, create_decompressor_block)
#   content_length            = 0
#   compressed_content_length = 0
#
#   compressed_time   = 0
#   decompressed_time = 0
#
#   open_pipe_with_processor create_compressor_block, :writer do |compressor, compressor_read_io, compressor_write_io|
#     open_pipe_with_processor create_decompressor_block, :reader do |decompressor, decompressor_read_io, decompressor_write_io|
#       # Compressor io -> decompressor io.
#
#       compressor_thread = Thread.new do
#         loop do
#           begin
#             compressed_content = compressor_read_io.read_nonblock MAX_COMPRESSOR_PORTION_LENGTH
#           rescue ::IO::WaitReadable
#             ::IO.select [compressor_read_io]
#             retry
#           rescue ::EOFError
#             break
#           end
#
#           compressed_content_length += compressed_content.length
#
#           decompressor_write_io.write compressed_content
#         end
#
#         decompressor_write_io.close
#       end
#
#       decompressor_thread = Thread.new do
#         loop do
#           begin
#             _decompressed_content, time = with_time { decompressor.read_nonblock MAX_DECOMPRESSOR_PORTION_LENGTH }
#           rescue ::IO::WaitReadable
#             ::IO.select [decompressor_read_io]
#             retry
#           rescue ::EOFError
#             break
#           end
#
#           decompressed_time += time
#         end
#       end
#
#       pathes.each.with_index do |path, index|
#         percent   = format_percent index, pathes.length
#         size_text = format_filesize File.size(path)
#
#         warn "- #{percent}% processing script, path: #{path}, size: #{size_text}"
#
#         content = File.read path
#         content_length += content.length
#
#         begin
#           _result, time = with_time { compressor.write_nonblock content }
#         rescue ::IO::WaitWritable
#           ::IO.select nil, [compressor_write_io]
#           retry
#         end
#
#         compressed_time += time
#       end
#
#       begin
#         _result, time = with_time { compressor.flush_nonblock }
#       rescue ::IO::WaitWritable
#         ::IO.select nil, [compressor_write_io]
#         retry
#       end
#
#       compressed_time += time
#
#       compressor.close
#
#       compressor_thread.join
#       decompressor_thread.join
#     end
#   end
#
#   ratio = content_length.to_f / compressed_content_length
#
#   total_content_text      = format_filesize content_length
#   compressed_content_text = format_filesize compressed_content_length
#   ratio_text              = format_float(ratio).light_green
#   compressed_time_text    = format_float compressed_time
#   decompressed_time_text  = format_float decompressed_time
#
#   warn "total content_length: #{total_content_text}, " \
#     "compressed content length: #{compressed_content_text}, " \
#     "ratio: #{ratio_text}, " \
#     "compressed time: #{compressed_time_text}, " \
#     "decompressed time: #{decompressed_time_text}"
#
#   {
#     :ratio             => ratio,
#     :compressed_time   => compressed_time,
#     :decompressed_time => decompressed_time
#   }
# end
