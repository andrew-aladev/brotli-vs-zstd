require "filesize"
require "shellwords"

require_relative "format"
require_relative "time"

MAX_COMPRESSOR_PORTION_LENGTH   = 1 << 21 # 2 MB
MAX_DECOMPRESSOR_PORTION_LENGTH = 1 << 23 # 8 MB

def get_script_pathes(mode)
  cdnjs_path = ENV["CDNJS_PATH"]
  raise StandardError, "cdnjs path is required" if cdnjs_path.nil? || cdnjs_path.empty?

  warn "reading cdnjs path: #{cdnjs_path}"

  command = ["find", Shellwords.shellescape(cdnjs_path), "-type", "f"]

  command <<
    case mode
    when :minified_only
      %w[-name *min.js]
    when :not_minified_only
      %w[-name *.js -not -name *min.js]
    else
      %w[-name *.js]
    end

  pathes = IO.popen(command.join(" ")) { |io| io.readlines :chomp => true }
  warn "found #{colorize_length(pathes.length)} script pathes"

  pathes
end

def get_script_stats(pathes, compress_block, decompress_block)
  pathes.map.with_index do |path, index|
    percent = format_percent index, pathes.length
    size    = File.size path
    warn "- #{percent}% processing script, path: #{path}, size: #{Filesize.new(size).pretty}"

    content = File.read path

    compressed_content,    compressed_time   = with_time { compress_block.call content }
    _decompressed_content, decompressed_time = with_time { decompress_block.call compressed_content }

    ratio = content.length.to_f / compressed_content.length

    warn "ratio: #{colorize_float(ratio)}, " \
      "compressed time: #{float_to_string(compressed_time)}, " \
      "decompressed time: #{float_to_string(decompressed_time)}"

    {
      :ratio             => ratio,
      :compressed_time   => compressed_time,
      :decompressed_time => decompressed_time
    }
  end
end

def open_pipe_with_processor(create_processor_block, mode, &_block)
  read_io, write_io = IO.pipe

  main_io =
    if mode == :writer
      write_io
    else
      read_io
    end

  begin
    processor = create_processor_block.call main_io

    begin
      yield processor, read_io, write_io
    ensure
      processor.close
    end
  ensure
    write_io.close
    read_io.close
  end
end

def get_all_scripts_stat(pathes, create_compressor_block, create_decompressor_block)
  content_length            = 0
  compressed_content_length = 0

  compressed_time   = 0
  decompressed_time = 0

  open_pipe_with_processor create_compressor_block, :writer do |compressor, compressor_read_io, compressor_write_io|
    open_pipe_with_processor create_decompressor_block, :reader do |decompressor, decompressor_read_io, decompressor_write_io|
      # Compressor io -> decompressor io.

      compressor_thread = Thread.new do
        loop do
          begin
            compressed_content = compressor_read_io.read_nonblock MAX_COMPRESSOR_PORTION_LENGTH
          rescue ::IO::WaitReadable
            ::IO.select [compressor_read_io]
            retry
          rescue ::EOFError
            break
          end

          compressed_content_length += compressed_content.length

          decompressor_write_io.write compressed_content
        end

        decompressor_write_io.close
      end

      decompressor_thread = Thread.new do
        loop do
          begin
            _decompressed_content, time = with_time { decompressor.read_nonblock MAX_DECOMPRESSOR_PORTION_LENGTH }
          rescue ::IO::WaitReadable
            ::IO.select [decompressor_read_io]
            retry
          rescue ::EOFError
            break
          end

          decompressed_time += time
        end
      end

      pathes.each.with_index do |path, index|
        percent = format_percent index, pathes.length
        size    = File.size path
        warn "- #{percent}% processing script, path: #{path}, size: #{Filesize.new(size).pretty}"

        content = File.read path
        content_length += content.length

        begin
          _result, time = with_time { compressor.write_nonblock content }
        rescue ::IO::WaitWritable
          ::IO.select nil, [compressor_write_io]
          retry
        end

        compressed_time += time
      end

      begin
        _result, time = with_time { compressor.flush_nonblock }
      rescue ::IO::WaitWritable
        ::IO.select nil, [compressor_write_io]
        retry
      end

      compressed_time += time

      compressor.close

      compressor_thread.join
      decompressor_thread.join
    end
  end

  ratio = content_length.to_f / compressed_content_length

  warn "total content_length: #{Filesize.new(content_length).pretty}, " \
    "compressed content length: #{Filesize.new(compressed_content_length).pretty}, " \
    "ratio: #{colorize_float(ratio)}, " \
    "compressed time: #{float_to_string(compressed_time)}, " \
    "decompressed time: #{float_to_string(decompressed_time)}"

  {
    :ratio             => ratio,
    :compressed_time   => compressed_time,
    :decompressed_time => decompressed_time
  }
end
