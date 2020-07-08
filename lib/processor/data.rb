require "brs"
require "zstds"

def get_brotli_compression_options(compression_level)
  { :quality => compression_level }
end

def get_zstd_compression_options(compression_level)
  { :compression_level => compression_level }
end

def raise_invalid_processor(type)
  raise StandardError, "invalid processor type: #{type}"
end

def compress(content, type, compression_level)
  case type
  when :brotli
    BRS::String.compress content, get_brotli_compression_options(compression_level)
  when :zstd
    ZSTDS::String.compress content, get_zstd_compression_options(compression_level)
  else
    raise_invalid_processor type
  end
end

def decompress(type, compressed_content)
  case type
  when :brotli
    BRS::String.decompress compressed_content
  when :zstd
    ZSTDS::String.decompress compressed_content
  else
    raise_invalid_processor type
  end
end

def create_compressor_data(type, compression_level)
  read_io, write_io = IO.pipe

  processor =
    case type
    when :brotli
      BRS::Stream::Writer.new write_io, get_brotli_compression_options(compression_level)
    when :zstd
      ZSTDS::Stream::Writer.new write_io, get_zstd_compression_options(compression_level)
    else
      raise_invalid_processor type
    end

  {
    :processor => processor,
    :write_io  => write_io,
    :read_io   => read_io
  }
end

def create_decompressor_data(type)
  read_io, write_io = IO.pipe

  processor =
    case type
    when :brotli
      BRS::Stream::Reader.new read_io
    when :zstd
      ZSTDS::Stream::Reader.new read_io
    else
      raise_invalid_processor type
    end

  {
    :processor => processor,
    :write_io  => write_io,
    :read_io   => read_io
  }
end

def close_processor_data(processor_data)
  processor_data[:processor].close
  processor_data[:write_io].close
  processor_data[:read_io].close
end
