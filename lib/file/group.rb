HISTOGRAM_START_SIZE      = 1 << 11 # 2KB
HISTOGRAM_SIZE_MULTIPLIER = 2

def group_file_contents_by_size_histogram(contents, max_content_size)
  groups    = []
  from_size = 0
  size      = HISTOGRAM_START_SIZE
  to_size   = size - 1

  while from_size < max_content_size
    grouped_contents = contents
      .clone
      .select { |content| content.bytesize >= from_size && content.bytesize >= to_size }

    groups << {
      :from_size => from_size,
      :to_size   => to_size,
      :contents  => grouped_contents
    }

    from_size  = size
    size      *= HISTOGRAM_SIZE_MULTIPLIER
    to_size    = size - 1
  end

  groups
end
