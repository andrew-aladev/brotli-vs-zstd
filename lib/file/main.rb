require_relative "../common/colorize"
require_relative "../common/format"
require_relative "../processor/main"
require_relative "data"
require_relative "find"
require_relative "group"

def process_files(vendor, root_path, option_groups)
  warn "-- processing files, vendor: #{vendor}, root path: #{root_path}"

  option_groups.each do |options|
    extension = options[:extension]
    type      = options[:type]
    data      = []

    pathes = find_file_pathes root_path, extension, type
    if pathes.empty?
      warn "no files for processing"
      next
    end

    pathes_length_text = colorize_length pathes.length
    warn "- processing #{pathes_length_text} files"

    processor_results = get_processor_results pathes
    data << processor_results.merge(
      :from_size => nil,
      :to_size   => nil
    )

    groups = group_file_pathes_by_size_histogram pathes
    groups.each do |group|
      from_size = group[:from_size]
      to_size   = group[:to_size]

      from_size_text = format_filesize from_size
      to_size_text   = format_filesize to_size

      group_pathes = group[:pathes]
      if group_pathes.empty?
        warn "files group is empty, from size: #{from_size_text}, to size: #{to_size_text}"
        next
      end

      group_pathes_length_text = colorize_length group_pathes.length

      warn "- processing group with #{group_pathes_length_text} files, " \
        "from size: #{from_size_text}, " \
        "to size: #{to_size_text}"

      processor_results = get_processor_results pathes
      data << processor_results.merge(
        :from_size => from_size,
        :to_size   => to_size
      )
    end

    save_files_data vendor, extension, type, data
  end
end
