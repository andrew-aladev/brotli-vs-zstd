HISTOGRAM_START_SIZE      = 1 << 11 # 2KB
HISTOGRAM_SIZE_MULTIPLIER = 2

def group_file_contents_by_size_histogram(contents_provider, max_content_size)
  boundaries   = []
  from_size    = 0
  size         = HISTOGRAM_START_SIZE
  to_size      = size - 1

  while from_size < max_content_size
    boundaries << {
      :from => from_size,
      :to   => to_size
    }

    from_size  = size
    size      *= HISTOGRAM_SIZE_MULTIPLIER
    to_size    = size - 1
  end

  boundaries.map do |boundary|
    from_size = boundary[:from]
    to_size   = boundary[:to]

    contents = contents_provider.call
      .select do |content|
        is_inside = content.bytesize >= boundary[:from] && content.bytesize <= boundary[:to]

        warn "content is outside boundaries" unless is_inside

        is_inside
      end

    {
      :from_size => from_size,
      :to_size   => to_size,
      :contents  => contents
    }
  end
end
