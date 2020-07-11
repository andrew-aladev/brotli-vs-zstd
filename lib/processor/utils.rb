require "brs"
require "zstds"

MAX_DECOMPRESSOR_PORTION_LENGTH = 1 << 18 # 256 KB

def write_compressor_nonblock(compressor, compressor_write_io, content)
  remaining_content = content
  processed_time    = 0

  IO.select nil, [compressor_write_io]

  loop do
    begin
      bytes_written, time = with_time { compressor.write_nonblock remaining_content }
    rescue IO::WaitWritable
      break
    end

    remaining_content  = remaining_content.byteslice bytes_written, remaining_content.bytesize - bytes_written
    processed_time    += time

    break if remaining_content.bytesize.zero?
  end

  [remaining_content, processed_time]
end

def flush_compressor_nonblock(compressor, compressor_write_io)
  result_is_flushed = false
  processed_time    = 0

  IO.select nil, [compressor_write_io]

  loop do
    begin
      is_flushed, time = with_time { compressor.flush_nonblock }
    rescue IO::WaitWritable
      break
    end

    result_is_flushed ||= is_flushed
    processed_time     += time

    break if result_is_flushed
  end

  [result_is_flushed, processed_time]
end

def read_decompressor_nonblock(decompressor, decompressor_read_io)
  result_decompressed_content = String.new :encoding => Encoding::BINARY
  is_finished                 = false
  processed_time              = 0

  IO.select [decompressor_read_io]

  loop do
    begin
      decompressed_content, time = with_time { decompressor.read_nonblock MAX_DECOMPRESSOR_PORTION_LENGTH }
    rescue IO::WaitReadable
      break
    rescue EOFError
      is_finished = true
      break
    end

    result_decompressed_content << decompressed_content
    processed_time += time
  end

  [result_decompressed_content, is_finished, processed_time]
end

def mirror_compressor_to_decompressor(compressor_read_io, decompressor_write_io)
  ;
end
