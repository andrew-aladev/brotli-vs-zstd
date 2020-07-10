require "brs"
require "zstds"

require_relative "../common/time"
require_relative "stat"

class Processor
  def initialize(type, compression_level)
    @type              = type
    @compression_level = compression_level

    @total_content  = String.new :encoding => Encoding::BINARY
    @total_result   = self.class.get_result
    @single_results = []

    init_compressor
    init_decompressor
  end

  protected def init_compressor
    @compressor_read_io, @compressor_write_io = IO.pipe

    compression_options = get_compression_options

    @compressor =
      case @type
      when :brotli
        BRS::Stream::Writer.new @compressor_write_io, compression_options
      when :zstd
        ZSTDS::Stream::Writer.new @compressor_write_io, compression_options
      else
        raise_invalid_processor_type
      end

    nil
  end

  protected def init_decompressor
    @decompressor_read_io, @decompressor_write_io = IO.pipe

    @decompressor =
      case @type
      when :brotli
        BRS::Stream::Reader.new @decompressor_read_io
      when :zstd
        ZSTDS::Stream::Reader.new @decompressor_read_io
      else
        raise_invalid_processor_type
      end

    nil
  end

  def process(content)
    new_total_result = get_total_result content
    @total_result    = self.class.sum_results @total_result, new_total_result

    new_single_result = get_single_result content
    @single_results << new_single_result

    nil
  end

  protected def get_total_result(_content)
    self.class.get_result
  end

  protected def get_single_result(content)
    compression_options = get_compression_options

    compressed_content, compress_time =
      case @type
      when :brotli
        with_time { BRS::String.compress content, compression_options }
      when :zstd
        with_time { ZSTDS::String.compress content, compression_options }
      else
        raise_invalid_processor_type
      end

    decompressed_content, decompress_time =
      case @type
      when :brotli
        with_time { BRS::String.decompress compressed_content }
      when :zstd
        with_time { ZSTDS::String.decompress compressed_content }
      else
        raise_invalid_processor_type
      end

    raise StandardError, "original content is not equal to decompressed content" \
      unless content == decompressed_content

    self.class.get_result(
      content.bytesize,
      compressed_content.bytesize,
      compress_time,
      decompress_time
    )
  end

  def close
    flush

    close_compressor
    close_decompressor

    nil
  end

  protected def flush
    new_total_result = get_last_total_result
    @total_result    = self.class.sum_results @total_result, new_total_result

    nil
  end

  protected def get_last_total_result
    is_compressor_flushed = false

    compress_time = 0

    loop do
      unless is_compressor_flushed
        is_compressor_flushed, new_compress_time = flush_compressor_nonblock
        compress_time += new_compress_time
      end

      break if is_compressor_flushed
    end

    self.class.get_result 0, 0, compress_time, 0
  end

  protected def flush_compressor_nonblock
    is_flushed     = false
    processed_time = 0

    IO.select nil, [@compressor_write_io]

    loop do
      begin
        result, time = with_time { @compressor.flush_nonblock }
      rescue IO::WaitWritable
        break
      end

      processed_time += time

      if result
        is_flushed = true
        break
      end
    end

    [is_flushed, processed_time]
  end

  protected def close_compressor
    @compressor.close
    @compressor_write_io.close
    @compressor_read_io.close

    nil
  end

  protected def close_decompressor
    @decompressor.close
    @decompressor_write_io.close
    @decompressor_read_io.close

    nil
  end

  def get_stats
    stats = get_stats_from_result_data @total_result, @single_results

    {
      :type              => @type,
      :compression_level => @compression_level
    }
    .merge stats
  end

  protected def get_compression_options
    case @type
    when :brotli
      { :quality => @compression_level }
    when :zstd
      { :compression_level => @compression_level }
    else
      raise_invalid_processor_type
    end
  end

  protected def raise_invalid_processor_type
    raise StandardError, "invalid processor, type: #{@type}"
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
