require "brs"
require "zstds"

# -- brotli --

BROTLI_COMPRESSOR_MAX_LEVEL_OPTIONS = {
  :quality => BRS::Option::MAX_QUALITY
}
.freeze

def brotli_compress(content)
  BRS::String.compress content
end

def brotli_compress_max_level(content)
  BRS::String.compress content, BROTLI_COMPRESSOR_MAX_LEVEL_OPTIONS
end

def brotli_decompress(compressed_content)
  BRS::String.decompress compressed_content
end

def brotli_create_compressor(io)
  BRS::Stream::Writer.new io
end

def brotli_create_compressor_max_level(io)
  BRS::Stream::Writer.new io, BROTLI_COMPRESSOR_MAX_LEVEL_OPTIONS
end

def brotli_create_decompressor(io)
  BRS::Stream::Reader.new io
end

# -- zstd --

ZSTD_COMPRESSOR_MAX_LEVEL_OPTIONS = {
  :compression_level => ZSTDS::Option::MAX_COMPRESSION_LEVEL
}
.freeze

def zstd_compress(content)
  ZSTDS::String.compress content
end

def zstd_compress_max_level(content)
  ZSTDS::String.compress content, ZSTD_COMPRESSOR_MAX_LEVEL_OPTIONS
end

def zstd_decompress(compressed_content)
  ZSTDS::String.decompress compressed_content
end

def zstd_create_compressor(io)
  ZSTDS::Stream::Writer.new io
end

def zstd_create_compressor_max_level(io)
  ZSTDS::Stream::Writer.new io, ZSTD_COMPRESSOR_MAX_LEVEL_OPTIONS
end

def zstd_create_decompressor(io)
  ZSTDS::Stream::Reader.new io
end
