require "brs"
require "zstds"

class Processor
  MAX_PORTION_LENGTH = 1 << 18 # 256 KB

  def self.write_nonblock(processor, write_io, content, need_time: true)
    remaining_content = content
    processed_time    = 0 if need_time

    IO.select nil, [write_io]

    loop do
      begin
        if need_time
          bytes_written, time = with_time { processor.write_nonblock remaining_content }
        else
          bytes_written = processor.write_nonblock remaining_content
        end
      rescue IO::WaitWritable
        break
      end

      remaining_content  = remaining_content.byteslice bytes_written, remaining_content.bytesize - bytes_written
      processed_time    += time if need_time

      break if remaining_content.bytesize.zero?
    end

    if need_time
      [remaining_content, processed_time]
    else
      remaining_content
    end
  end

  def self.flush_nonblock(processor, write_io, need_time: true)
    total_is_flushed = false
    processed_time   = 0 if need_time

    IO.select nil, [write_io]

    loop do
      begin
        if need_time
          is_flushed, time = with_time { processor.flush_nonblock }
        else
          is_flushed = processor.flush_nonblock
        end
      rescue IO::WaitWritable
        break
      end

      total_is_flushed ||= is_flushed
      processed_time    += time if need_time

      break if total_is_flushed
    end

    if need_time
      [total_is_flushed, processed_time]
    else
      total_is_flushed
    end
  end

  def self.read_nonblock(processor, read_io, need_time: true)
    total_content  = String.new :encoding => Encoding::BINARY
    is_finished    = false
    processed_time = 0 if need_time

    IO.select [read_io]

    loop do
      begin
        if need_time
          content, time = with_time { processor.read_nonblock MAX_PORTION_LENGTH }
        else
          content = processor.read_nonblock MAX_PORTION_LENGTH
        end
      rescue IO::WaitReadable
        break
      rescue EOFError
        is_finished = true
        break
      end

      total_content << content
      processed_time += time if need_time
    end

    if need_time
      [total_content, is_finished, processed_time]
    else
      [total_content, is_finished]
    end
  end

  def self.sum_results(result_1, result_2)
    result_1.keys.each_with_object({}) do |key, result|
      result[key] = result_1[key] + result_2[key]
    end
  end

  def self.get_result(content_size = 0, compressed_content_size = 0, compress_time = 0, decompress_time = 0)
    {
      :content_size            => content_size,
      :compressed_content_size => compressed_content_size,
      :compress_time           => compress_time,
      :decompress_time         => decompress_time
    }
  end
end
