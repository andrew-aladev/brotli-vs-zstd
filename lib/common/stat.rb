require_relative "colorize"
require_relative "format"
require_relative "time"

MAX_DECOMPRESSOR_PORTION_LENGTH = 1 << 20 # 1 MB

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

def open_processors(create_compressor_block, create_decompressor_block, &_block)
  IO.pipe do |read_io, write_io|
    open_processor create_compressor_block, write_io do |compressor|
      open_processor create_decompressor_block, read_io do |decompressor|
        yield compressor, write_io, decompressor, read_io
      end
    end
  end
end

def write_nonblock(processor, write_io, content)
  processed_time = 0

  IO.select nil, [write_io]

  loop do
    begin
      bytes_written, time = with_time { processor.write_nonblock content }
    rescue IO::WaitWritable
      break
    end

    content = content.byteslice bytes_written, content.bytesize - bytes_written
    processed_time += time
  end

  [content, processed_time]
end

def flush_nonblock(processor, write_io)
  processed_time = 0

  IO.select nil, [write_io]

  loop do
    begin
      is_flushed, time = with_time { processor.flush_nonblock content }
    rescue IO::WaitWritable
      break
    end

    processed_time += time

    if is_flushed
      processor.close
      break
    end
  end

  processed_time
end

def read_nonblock(processor, read_io)
  content        = String.new :encoding => Encoding::BINARY
  processed_time = 0

  IO.select [read_io]

  loop do
    begin
      decompressed_content, time = with_time { processor.read_nonblock MAX_DECOMPRESSOR_PORTION_LENGTH }
    rescue IO::WaitReadable
      break
    rescue EOFError
      processor.close
      break
    end

    content << decompressed_content
    processed_time += time
  end

  [content, processed_time]
end

def collect_files_group_stat(file_pathes, create_compressor_block, create_decompressor_block)
  warn "collecting files group stat"

  content_size            = 0
  compressed_content_size = 0
  compress_time           = 0
  decompress_time         = 0

  open_processors create_compressor_block, create_decompressor_block do |compressor, write_io, decompressor, read_io|
    process_files file_pathes do |content|
      content_size += content.bytesize

      until content.empty?
        content, compress_time = write_nonblock compressor, write_io, content
      end
    end

    ;
  end

  get_stat(
    content_size,
    compressed_content_size,
    compress_time,
    decompress_time
  )
end

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
#           rescue IO::WaitReadable
#             IO.select [compressor_read_io]
#             retry
#           rescue EOFError
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
#           rescue IO::WaitReadable
#             IO.select [decompressor_read_io]
#             retry
#           rescue EOFError
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
#         rescue IO::WaitWritable
#           IO.select nil, [compressor_write_io]
#           retry
#         end
#
#         compressed_time += time
#       end
#
#       begin
#         _result, time = with_time { compressor.flush_nonblock }
#       rescue IO::WaitWritable
#         IO.select nil, [compressor_write_io]
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
