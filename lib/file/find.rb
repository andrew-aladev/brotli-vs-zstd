require "digest"
require "find"
require "set"

require_relative "../common/format"

MIN_PATTERN = "[._/-]min".freeze

def get_path_regexp(extension, type)
  pattern =
    case type
    when :min
      "(?<=#{MIN_PATTERN})"
    when :not_min
      "(?<!#{MIN_PATTERN})"
    else
      ""
    end

  pattern << "\\.#{extension}$"

  Regexp.new pattern, Regexp::IGNORECASE
end

# Total amount of files will be about several billions.
# We have to use lazy find.

def find_file_contents(root_path, extension, type)
  regexp = get_path_regexp extension, type

  file_pathes = Find.find(root_path)
    .lazy
    .select { |path| File.file?(path) && regexp.match?(path) }

  file_contents = file_pathes.map do |path|
    content   = File.open path, "rb", &:read
    size_text = format_filesize content.bytesize

    warn "read path: #{path}, size: #{size_text}"

    content
  end

  digests = Set.new

  file_contents.reject do |content|
    digest       = Digest::SHA256.digest content
    is_duplicate = digests.include? digest

    if is_duplicate
      warn "found file duplicate, ignoring"
    else
      digests << digest
    end

    is_duplicate
  end
end
