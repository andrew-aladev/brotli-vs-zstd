def get_stat(content_size, compressed_content_size, compress_time, decompress_time)
  {
    :content_size           => content_size,
    :ratio                  => content_size.to_f / compressed_content_size,
    :compress_performance   => content_size.to_f / compress_time,
    :decompress_performance => compressed_content_size.to_f / decompress_time
  }
end
