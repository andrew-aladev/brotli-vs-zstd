require_relative "../common/time"
require_relative "data"
require_relative "files"

def collect_single_file_stats(file_pathes, compressor_options_combinations, compress_block, decompress_block)
  warn "collecting file stats"

  total_content_size            = 0
  total_compressed_content_size = 0
  total_compress_time           = 0
  total_decompress_time         = 0

  stats = process_files file_pathes, compressor_options_combinations do |content, compressor_options|
    compressed_content,   compress_time   = with_time { compress_block.call content, compressor_options }
    decompressed_content, decompress_time = with_time { decompress_block.call compressed_content }

    raise StandardError, "decompressed content does not equal to original content" unless decompressed_content == content

    content_size            = content.bytesize
    compressed_content_size = compressed_content.bytesize

    total_content_size            += content_size
    total_compressed_content_size += compressed_content_size
    total_compress_time           += compress_time
    total_decompress_time         += decompress_time

    get_stat(
      content_size,
      compressed_content_size,
      compress_time,
      decompress_time
    )
  end

  total = get_stat(
    total_content_size,
    total_compressed_content_size,
    total_compress_time,
    total_decompress_time
  )

  {
    :files => stats,
    :total => total
  }
end
