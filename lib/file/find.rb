require "digest"
require "find"
require "set"

require_relative "../common/format"

def get_path_regexp(extension, type)
  data =
    case type
    when :min
      "
        (?<=
          \.min
          \-min
          \.mini
          \-mini
        )
      "
    when :not_min
      "
        (?<!
          \.min
          \-min
          \.mini
          \-mini
        )
      "
    else
      ""
    end

  data << "\.#{extension}$"

  Regexp.new data, Regexp::IGNORECASE | Regexp::EXTENDED
end

def find_file_pathes(root_path, extension, type)
  warn "- reading files from root path: #{root_path}, extension: #{extension}, type: #{type}"

  regexp  = get_path_regexp extension, type
  digests = Set.new

  Find.find(root_path)
    .lazy
    .select do |path|
      next false unless regexp.match? path

      content   = File.open path, "rb", &:read
      size_text = format_filesize content.bytesize

      warn "reading path: #{path}, size: #{size_text}"

      digest       = Digest::SHA256.digest content
      is_duplicate = digests.include? digest
      digests << digest

      !is_duplicate
    end
end
