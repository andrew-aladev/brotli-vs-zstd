require_relative "../common/time"

class Processor
  # 256 KB is enough for both compressor and decompressor.
  MAX_PORTION_LENGTH = 1 << 18

  def self.write_and_read(writer, reader, content, &_read_block)
    return 0 if content.bytesize.zero?

    total_writing_time = 0
    modes              = %i[write]
    read_io            = get_io reader
    write_io           = get_io writer

    loop do
      yield with_time { reader.read_nonblock MAX_PORTION_LENGTH } if modes.include? :read

      if modes.include? :write
        bytes_written, writing_time = with_time { writer.write_nonblock content }

        content             = content.byteslice bytes_written, content.bytesize - bytes_written
        total_writing_time += writing_time

        break if content.bytesize.zero?
      end

    rescue IO::WaitWritable, IO::WaitReadable
      modes = wait read_io, write_io
      raise StandardError, "IO is not writable or readable" if modes.empty?

      next
    end

    total_writing_time
  end

  def self.close_and_read(writer, reader, &_read_block)
    total_is_flushed   = false
    total_closing_time = 0
    modes              = %i[write]
    read_io            = get_io reader
    write_io           = get_io writer

    loop do
      if modes.include? :read
        begin
          yield with_time { reader.read_nonblock MAX_PORTION_LENGTH }
        rescue EOFError
          break
        end
      end

      if modes.include? :write
        if total_is_flushed
          if writer.respond_to? :close_nonblock
            is_closed, closing_time = with_time { writer.close_nonblock }
          else
            _result, closing_time = with_time { writer.close }
            is_closed = true
          end

          total_closing_time += closing_time

          # We may need to read remaining data.
          modes = [:read] if is_closed
        else
          if writer.respond_to? :flush_nonblock
            is_flushed, flushing_time = with_time { writer.flush_nonblock }
          else
            _result, flushing_time = with_time { writer.flush }
            is_flushed = true
          end

          total_closing_time += flushing_time

          total_is_flushed = true if is_flushed
        end
      end

    rescue IO::WaitWritable, IO::WaitReadable
      modes = wait read_io, write_io
      raise StandardError, "IO is not writable or readable" if modes.empty?

      next
    end

    total_closing_time
  end

  def self.get_io(processor)
    return processor.io if processor.respond_to? :io

    processor
  end

  def self.wait(read_io, write_io)
    result = IO.select [read_io], [write_io]
    return [] if result.nil?

    modes = []

    read_ios = result[0]
    modes << :read if read_ios.include? read_io

    write_ios = result[1]
    modes << :write if write_ios.include? write_io

    modes
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
