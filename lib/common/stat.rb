require_relative "colorize"
require_relative "format"
require_relative "time"

def get_stat(content_size, compressed_content_size, compress_time, decompress_time)
  {
    :content_size           => content_size,
    :ratio                  => content_size.to_f / compressed_content_size,
    :compress_performance   => content_size.to_f / compress_time,
    :decompress_performance => compressed_content_size.to_f / decompress_time
  }
end

def process_files(file_pathes, &_block)
  file_pathes.map.with_index do |path, index|
    content = File.read path

    percent   = format_percent index, file_pathes.length
    size_text = format_filesize content.bytesize

    warn "- #{percent}% processing script, path: #{path}, size: #{size_text}"

    yield content
  end
end

def collect_file_stats(file_pathes, compress_block, decompress_block)
  warn "collecting file stats"

  total_content_size            = 0
  total_compressed_content_size = 0
  total_compress_time           = 0
  total_decompress_time         = 0

  stats = process_files file_pathes do |content|
    compressed_content,   compress_time   = with_time { compress_block.call content }
    decompressed_content, decompress_time = with_time { decompress_block.call compressed_content }

    raise StandardError, "decompressed content does not equal to original content" unless decompressed_content == content

    content_size            = content.bytesize
    compressed_content_size = compressed_content.bytesize

    total_content_size            += content_size
    total_compressed_content_size += compressed_content_size
    total_compress_time           += compress_time
    total_decompress_time         += decompress_time

    get_stat(
      content_size,
      compressed_content_size,
      compress_time,
      decompress_time
    )
  end

  total = get_stat(
    total_content_size,
    total_compressed_content_size,
    total_compress_time,
    total_decompress_time
  )

  {
    :files => stats,
    :total => total
  }
end

def open_processor(create_processor_block, io, &_block)
  processor = create_processor_block.call io

  begin
    yield processor
  ensure
    processor.close
  end
end

def collect_files_group_stat(file_pathes, create_compressor_block, create_decompressor_block)
  warn "collecting files group stat"

  content_size            = 0
  compressed_content_size = 0
  compress_time           = 0
  decompress_time         = 0

  IO.pipe do |read_io, write_io|
    open_processor create_compressor_block, write_io do |compressor|
      open_processor create_decompressor_block, read_io do |decompressor|
        process_files file_pathes do |content|
          content_size += content.bytesize
        end

        begin
          compressor.flush_nonblock
        rescue ::IO::WaitWritable
          ;
        end
      end
    end
  end

  get_stat(
    content_size,
    compressed_content_size,
    compress_time,
    decompress_time
  )
end

# MAX_COMPRESSOR_PORTION_LENGTH   = 1 << 21 # 2 MB
# MAX_DECOMPRESSOR_PORTION_LENGTH = 1 << 23 # 8 MB

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
# end
