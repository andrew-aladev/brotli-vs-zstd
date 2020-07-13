require_relative "../common/colorize"
require_relative "../common/format"

DEFAULT_HISTOGRAM_START_SIZE      = 1 << 11 # 2KB
DEFAULT_HISTOGRAM_SIZE_MULTIPLIER = 2

def group_file_pathes_by_size_histogram(pathes, start_size: DEFAULT_HISTOGRAM_START_SIZE, size_multiplier: DEFAULT_HISTOGRAM_SIZE_MULTIPLIER)
  warn "collecting file sizes"

  objects = pathes.map do |path|
    {
      :path => path,
      :size => File.size(path)
    }
  end

  start_size_text = format_filesize start_size
  warn "- grouping file pathes by histogram, start size: #{start_size_text}, size multiplier: #{size_multiplier}"

  groups    = []
  from_size = 0
  size      = start_size
  to_size   = size - 1

  until objects.empty?
    pathes = []

    objects = objects.filter do |object|
      next true if object[:size] > to_size

      pathes << object[:path]

      false
    end

    groups << {
      :from_size => from_size,
      :to_size   => to_size,
      :pathes    => pathes
    }

    from_size  = size
    size      *= size_multiplier
    to_size    = size - 1
  end

  groups_text = colorize_length groups.length
  warn "found #{groups_text} file groups"

  groups
end
