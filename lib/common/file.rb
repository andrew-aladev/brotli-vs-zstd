require "shellwords"

require_relative "colorize"

DEFAULT_HISTOGRAM_START_SIZE      = 1 << 12 # 4KB
DEFAULT_HISTOGRAM_SIZE_MULTIPLIER = 2

def find_file_command(mode, postfix)
  case mode
  when :minified_only
    ["-name", "*min.#{postfix}"]
  when :not_minified_only
    ["-name", "*.#{postfix}", "-not", "-name", "*min.#{postfix}"]
  else
    ["-name", "*.#{postfix}"]
  end
end

def find_file_pathes(root_path, mode, &_block)
  raise StandardError, "root path is required" if root_path.blank?

  warn "reading files from path: #{root_path}"

  command = ["find", Shellwords.shellescape(root_path), "-type", "f"]
  command << yield(mode)

  pathes = IO.popen(command.join(" ")) { |io| io.readlines :chomp => true }

  pathes_text = colorize_length pathes.length
  warn "found #{pathes_text} file pathes"

  pathes
end

def group_file_pathes_by_size_histogram(file_pathes, start_size = DEFAULT_HISTOGRAM_START_SIZE, size_multiplier = DEFAULT_HISTOGRAM_SIZE_MULTIPLIER)
  warn "collecting file sizes"

  objects = file_pathes.map do |path|
    {
      :path => path,
      :size => File.size(path)
    }
  end

  warn "grouping file pathes by histogram"

  groups    = []
  prev_size = 0
  size      = start_size

  until objects.empty?
    pathes = []

    objects = objects.filter do |object|
      next true if object[:size] >= size

      pathes << object[:path]

      false
    end

    groups << {
      :prev_size => prev_size,
      :size      => size,
      :pathes    => pathes
    }

    prev_size  = size
    size      *= size_multiplier
  end

  groups_text = colorize_length groups.length
  warn "found #{groups_text} file groups"

  groups
end
