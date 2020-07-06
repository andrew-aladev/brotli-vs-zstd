require "brs"
require "zstds"

PROCESSOR_TYPES = %i[brotli zstd].freeze

COMPRESSION_LEVELS = {
  :brotli => BRS::Option::MIN_QUALITY..BRS::Option::MAX_QUALITY,
  :zstd   => 0..ZSTDS::Option::MAX_COMPRESSION_LEVEL
}
.freeze

def get_brotli_compression_options(level)
  { :quality => level }
end

def get_zstd_compression_options(level)
  { :compression_level => level }
end

def raise_invalid_processor(type)
  raise StandardError, "invalid processor type: #{type}"
end

def compress(content, type, level)
  case type
  when :brotli
    BRS::String.compress content, get_brotli_compression_options(level)
  when :zstd
    ZSTDS::String.compress content, get_zstd_compression_options(level)
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

def create_compressor(io, type, level)
  case type
  when :brotli
    BRS::Stream::Writer.new io, get_brotli_compression_options(level)
  when :zstd
    ZSTDS::Stream::Writer.new io, get_brotli_compression_options(level)
  else
    raise_invalid_processor type
  end
end

def create_decompressor(type, io)
  case type
  when :brotli
    BRS::Stream::Reader.new io
  when :zstd
    ZSTDS::Stream::Reader.new io
  else
    raise_invalid_processor type
  end
end
