require "brs"
require "zstds"

BROTLI_COMPRESSOR_COMBINATION_OPTIONS = {
  :quality => (BRS::Option::MIN_QUALITY..BRS::Option::MAX_QUALITY)
}
.freeze

ZSTD_COMPRESSOR_COMBINATION_OPTIONS = {
  :compression_level => (0..ZSTDS::Option::MAX_COMPRESSION_LEVEL)
}
.freeze

# -- brotli --

def brotli_compress(content, options)
  BRS::String.compress content, options
end

def brotli_decompress(compressed_content)
  BRS::String.decompress compressed_content
end

def brotli_create_compressor(io, options)
  BRS::Stream::Writer.new io, options
end

def brotli_create_decompressor(io)
  BRS::Stream::Reader.new io
end

# -- zstd --

def zstd_compress(content, options)
  ZSTDS::String.compress content, options
end

def zstd_decompress(compressed_content)
  ZSTDS::String.decompress compressed_content
end

def zstd_create_compressor(io, options)
  ZSTDS::Stream::Writer.new io, options
end

def zstd_create_decompressor(io)
  ZSTDS::Stream::Reader.new io
end
