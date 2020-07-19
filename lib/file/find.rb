require "set"
require "digest"
require "shellwords"

require_relative "../common/colorize"

def find_file_command(extension, type)
  case type
  when :min
    [
      "-name", "'*.min.#{extension}'",
      "-o", "-name", "'*-min.#{extension}'",
      "-o", "-name", "'*.mini.#{extension}'",
      "-o", "-name", "'*-mini.#{extension}'"
    ]
  when :not_min
    [
      "-name", "'*.#{extension}'",
      "-not", "-name", "'*.min.#{extension}'",
      "-not", "-name", "'*-min.#{extension}'",
      "-not", "-name", "'*.mini.#{extension}'",
      "-not", "-name", "'*-mini.#{extension}'"
    ]
  else
    ["-name", "'*.#{extension}'"]
  end
end

def reject_file_duplicates(pathes)
  warn "rejecting file duplicates"

  digests = Set.new

  pathes.reject do |path|
    content = File.open path, "rb", &:read
    digest  = Digest::SHA256.digest content

    is_duplicate = digests.include? digest
    digests << digest

    is_duplicate
  end
end

def find_file_pathes(root_path, extension, type)
  raise StandardError, "root path is required" if root_path.nil? || root_path.empty?

  command = ["find", Shellwords.shellescape(root_path), "-type", "f"]
  command << find_file_command(extension, type)
  command = command.join " "

  warn "- reading files from root path: #{root_path}, extension: #{extension}, type: #{type}"

  pathes = IO.popen(command) { |io| io.readlines :chomp => true }
  pathes = reject_file_duplicates pathes

  pathes_text = colorize_length pathes.length
  warn "found #{pathes_text} file pathes"

  pathes.sort
end
