require "brs"
require "zstds"

require_relative "../common/time"

class Processor
  MAX_PORTION_LENGTH = 1 << 18 # 256 KB

  def self.write(processor, write_io, content, &_block)
    return nil if content.bytesize.zero?

    loop do
      wait_writable write_io

      begin
        bytes_written, time = with_time { processor.write_nonblock content }
      rescue IO::WaitWritable
        yield 0
        next
      end

      yield time

      content = content.byteslice bytes_written, content.bytesize - bytes_written
      break if content.bytesize.zero?
    end

    nil
  end

  def self.flush(processor, write_io, &_block)
    loop do
      wait_writable write_io

      begin
        is_flushed, time = with_time { processor.flush_nonblock }
      rescue IO::WaitWritable
        yield 0
        next
      end

      yield time

      break if is_flushed
    end

    nil
  end

  def self.read(processor, read_io, &_block)
    loop do
      break unless wait_readable read_io

      begin
        content, time = with_time { processor.read_nonblock MAX_PORTION_LENGTH }
      rescue IO::WaitReadable
        next
      end

      yield content, time
    end

    nil
  end

  def self.wait_writable(io)
    result = IO.select nil, [io]
    return false if result.nil?

    ios = result[1]
    return false if ios.nil? || !ios.include?(io)

    true
  end

  def self.wait_readable(io)
    result = IO.select [io], nil, nil, 0
    return false if result.nil?

    ios = result[0]
    return false if ios.nil? || !ios.include?(io)

    true
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
