require "brs"
require "zstds"

class Processor
  MAX_PORTION_LENGTH = 1 << 18 # 256 KB

  def self.write_nonblock(processor, write_io, content)
    remaining_content = content
    processed_time    = 0

    IO.select nil, [write_io]

    loop do
      begin
        bytes_written, time = with_time { processor.write_nonblock remaining_content }
      rescue IO::WaitWritable
        break
      end

      remaining_content  = remaining_content.byteslice bytes_written, remaining_content.bytesize - bytes_written
      processed_time    += time

      break if remaining_content.bytesize.zero?
    end

    [remaining_content, processed_time]
  end

  def self.flush_nonblock(processor, write_io)
    total_is_flushed = false
    processed_time   = 0

    IO.select nil, [write_io]

    loop do
      begin
        is_flushed, time = with_time { processor.flush_nonblock }
      rescue IO::WaitWritable
        break
      end

      total_is_flushed ||= is_flushed
      processed_time    += time

      break if total_is_flushed
    end

    [total_is_flushed, processed_time]
  end

  def self.read_nonblock(processor, read_io)
    total_content  = String.new :encoding => Encoding::BINARY
    is_finished    = false
    processed_time = 0

    IO.select [read_io]

    loop do
      begin
        content, time = with_time { processor.read_nonblock MAX_PORTION_LENGTH }
      rescue IO::WaitReadable
        break
      rescue EOFError
        is_finished = true
        break
      end

      total_content << content
      processed_time += time
    end

    [total_content, is_finished, processed_time]
  end

  def self.mirror_content(read_io, write_io)
    remaining_content  = String.new :encoding => Encoding::BINARY
    is_finished        = false
    total_content_size = 0

    loop do
      IO.select [read_io]

      begin
        content = read_io.read_nonblock MAX_PORTION_LENGTH
      rescue IO::WaitReadable
        break
      rescue EOFError
        is_finished = true
        break
      end

      remaining_content << content
      total_content_size += content.bytesize

      loop do
        IO.select nil, [write_io]

        begin
          bytes_written = write_io.write_nonblock remaining_content
        rescue IO::WaitWritable
          break
        end

        remaining_content = remaining_content.byteslice bytes_written, remaining_content.bytesize - bytes_written

        break if remaining_content.bytesize.zero?
      end
    end

    [total_content_size, is_finished]
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
