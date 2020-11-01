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

    contents = find_file_contents root_path, extension, type

    # Enumerator is lazy, we can find max content size during first processing (without groups).
    max_content_size = 0

    all_contents = contents
      .clone
      .reject do |content|
        max_content_size = content.bytesize if max_content_size < content.bytesize
        false
      end

    warn "- processing all files, extension: #{extension}, type: #{type}"

    stats, count = get_processor_stats all_contents
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

    groups = group_file_contents_by_size_histogram contents, max_content_size
    groups.each do |group|
      from_size      = group[:from_size]
      to_size        = group[:to_size]
      group_contents = group[:contents]

      from_size_text = format_filesize from_size
      to_size_text   = format_filesize to_size

      warn "- processing group of files, " \
        "extension: #{extension}, " \
        "type: #{type}, " \
        "from size: #{from_size_text}, " \
        "to size: #{to_size_text}"

      stats, count = get_processor_stats group_contents
      if count.zero?
        warn "group of files is empty, from size: #{from_size_text}, to size: #{to_size_text}"
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
