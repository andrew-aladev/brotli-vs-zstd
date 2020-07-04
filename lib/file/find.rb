require "shellwords"

require_relative "../common/colorize"

def find_file_command(postfix, type)
  case type
  when :min
    [
      "-name", "'*.min.#{postfix}'",
      "-o", "-name", "'*-min.#{postfix}'",
      "-o", "-name", "'*.mini.#{postfix}'",
      "-o", "-name", "'*-mini.#{postfix}'"
    ]
  when :not_min
    [
      "-name", "'*.#{postfix}'",
      "-not", "-name", "'*.min.#{postfix}'",
      "-not", "-name", "'*-min.#{postfix}'",
      "-not", "-name", "'*.mini.#{postfix}'",
      "-not", "-name", "'*-mini.#{postfix}'"
    ]
  else
    ["-name", "'*.#{postfix}'"]
  end
end

def find_file_pathes(root_path, postfix, type)
  raise StandardError, "root path is required" if root_path.nil? || root_path.empty?

  command = ["find", Shellwords.shellescape(root_path), "-type", "f"]
  command << find_file_command(postfix, type)
  command = command.join " "

  warn "reading files from root path: #{root_path}, command: #{command}"

  pathes = IO.popen(command) { |io| io.readlines :chomp => true }

  pathes_text = colorize_length pathes.length
  warn "found #{pathes_text} file pathes"

  pathes
end
