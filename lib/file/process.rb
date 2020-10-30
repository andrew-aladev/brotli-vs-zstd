require_relative "data"
require_relative "find"
# require_relative "group"

require_relative "../processor/main"

def process_files(vendor, root_path, option_groups)
  warn "-- processing files, vendor: #{vendor}, root path: #{root_path}"

  option_groups.each do |options|
    extension = options[:extension]
    type      = options[:type]
    data      = []

    contents     = find_file_contents root_path, extension, type
    stats, count = get_processor_stats contents
    data << {
      :from_size => nil,
      :to_size   => nil,
      :count     => count,
      :stats     => stats
    }

    save_files_data vendor, extension, type, data
  end

  nil
end

# def process_files(vendor, root_path, option_groups)
#   option_groups.each do |options|
#     groups = group_file_pathes_by_size_histogram pathes
#     groups.each do |group|
#       from_size = group[:from_size]
#       to_size   = group[:to_size]
#
#       from_size_text = format_filesize from_size
#       to_size_text   = format_filesize to_size
#
#       group_pathes = group[:pathes]
#       if group_pathes.empty?
#         warn "files group is empty, from size: #{from_size_text}, to size: #{to_size_text}"
#         next
#       end
#
#       group_pathes_length_text = colorize_length group_pathes.length
#
#       warn "-- processing group with #{group_pathes_length_text} files, " \
#         "from size: #{from_size_text}, " \
#         "to size: #{to_size_text}"
#
#       stats = get_processor_stats group_pathes
#       data << {
#         :from_size => from_size,
#         :to_size   => to_size,
#         :count     => group_pathes.length,
#         :stats     => stats
#       }
#     end
#
#     save_files_data vendor, extension, type, data
#   end
# end
