require "brs"
require "zstds"

require_relative "../common/time"
require_relative "stat"
require_relative "utils"

class Processor
  def initialize(type, compression_level)
    @type              = type
    @compression_level = compression_level

    @total_remaining_content = String.new :encoding => Encoding::BINARY
    @total_result            = self.class.get_result

    @single_results = []

    init_compressor
    init_decompressor
  end

  protected def init_compressor
    @compressor_read_io, compressor_write_io = IO.pipe
    compression_options                      = get_compression_options

    @compressor =
      case @type
      when :brotli
        BRS::Stream::Writer.new compressor_write_io, compression_options
      when :zstd
        ZSTDS::Stream::Writer.new compressor_write_io, compression_options
      else
        raise_invalid_processor_type
      end
  end

  protected def init_decompressor
    decompressor_read_io, @decompressor_write_io = IO.pipe

    @decompressor =
      case @type
      when :brotli
        BRS::Stream::Reader.new decompressor_read_io
      when :zstd
        ZSTDS::Stream::Reader.new decompressor_read_io
      else
        raise_invalid_processor_type
      end
  end

  def process(content)
    total_result  = get_total_result content
    @total_result = self.class.sum_results @total_result, total_result

    single_result = get_single_result content
    @single_results << single_result

    nil
  end

  protected def get_total_result(content)
    @total_remaining_content << content

    total_compressed_content_size = 0
    total_decompress_time         = 0

    total_compress_time = self.class.write_and_read @compressor, @compressor_read_io, content do |compressed_content, _read_time|
      total_compressed_content_size += compressed_content.bytesize

      self.class.write_and_read @decompressor_write_io, @decompressor, compressed_content do |decompressed_content, decompress_time|
        process_total_decompressed_content decompressed_content
        total_decompress_time += decompress_time
      end
    end

    self.class.get_result(
      content.bytesize,
      total_compressed_content_size,
      total_compress_time,
      total_decompress_time
    )
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

    raise StandardError, "received invalid decompressed content" \
      unless content == decompressed_content

    self.class.get_result(
      content.bytesize,
      compressed_content.bytesize,
      compress_time,
      decompress_time
    )
  end

  def close
    total_result  = get_last_total_result
    @total_result = self.class.sum_results @total_result, total_result

    raise StandardError, "remaining content is not empty" \
      unless @total_remaining_content.empty?

    @compressor.close
    @compressor_read_io.close
    @decompressor_write_io.close
    @decompressor.close

    nil
  end

  protected def get_last_total_result
    total_compressed_content_size = 0
    total_decompress_time         = 0

    total_compress_time = self.class.close_and_read @compressor, @compressor_read_io do |compressed_content, _read_time|
      total_compressed_content_size += compressed_content.bytesize

      self.class.write_and_read @decompressor_write_io, @decompressor, compressed_content do |decompressed_content, decompress_time|
        process_total_decompressed_content decompressed_content
        total_decompress_time += decompress_time
      end
    end

    self.class.close_and_read @decompressor_write_io, @decompressor do |decompressed_content, decompress_time|
      process_total_decompressed_content decompressed_content
      total_decompress_time += decompress_time
    end

    self.class.get_result(
      0,
      total_compressed_content_size,
      total_compress_time,
      total_decompress_time
    )
  end

  protected def process_total_decompressed_content(decompressed_content)
    raise StandardError, "received invalid decompressed content" \
      unless @total_remaining_content.start_with? decompressed_content

    @total_remaining_content = @total_remaining_content.byteslice(
      decompressed_content.bytesize,
      @total_remaining_content.bytesize - decompressed_content.bytesize
    )
  end

  def get_stats
    stats = get_stats_from_results @total_result, @single_results

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
end
