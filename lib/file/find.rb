require "shellwords"

require_relative "../common/colorize"

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

def find_file_pathes(root_path, &_block)
  raise StandardError, "root path is required" if root_path.blank?

  command = ["find", Shellwords.shellescape(root_path), "-type", "f"]
  command << yield
  command = command.join " "

  warn "reading files from root path: #{root_path}, command: #{command}"

  pathes = IO.popen(command) { |io| io.readlines :chomp => true }

  pathes_text = colorize_length pathes.length
  warn "found #{pathes_text} file pathes"

  pathes
end
