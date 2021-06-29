require_relative "data"
require_relative "find"
require_relative "group"

require_relative "../processor/main"

def process_files(vendor, root_path, option_groups)
  warn "-- processing files, vendor: #{vendor}, root path: #{root_path}"

  option_groups.each do |options|
    extension = options[:extension]
    type      = options[:type]
    data      = []

    contents_provider = proc { find_file_contents root_path, extension, type }

    warn "- processing all files, extension: #{extension}, type: #{type}"

    stats, count, max_size = get_processor_stats contents_provider, :need_max_size => true
    if count.zero?
      warn "there are no files"
      next
    end

    data << {
      :from_size => nil,
      :to_size   => nil,
      :count     => count,
      :stats     => stats
    }

    groups = group_file_contents_by_size_histogram contents_provider, max_size
    groups.each do |group|
      from_size      = group[:from_size]
      to_size        = group[:to_size]
      group_provider = group[:provider]

      from_size_text = format_filesize from_size
      to_size_text   = format_filesize to_size

      warn \
        "- processing group of files, " \
        "extension: #{extension}, " \
        "type: #{type}, " \
        "from size: #{from_size_text}, " \
        "to size: #{to_size_text}"

      stats, count = get_processor_stats group_provider
      if count.zero?
        warn "group of files is empty"
        next
      end

      data << {
        :from_size => from_size,
        :to_size   => to_size,
        :count     => count,
        :stats     => stats
      }
    end

    save_files_data vendor, extension, type, data
  end

  nil
end
