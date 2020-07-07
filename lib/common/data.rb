require "fileutils"
require "yaml"

DATA_PATH      = File.join(File.dirname(__FILE__), "..", "..", "data").freeze
DATA_EXTENSION = ".yml".freeze

def load_data(directory_names, file_name)
  file_path = File.join DATA_PATH, *directory_names, "#{file_name}#{DATA_EXTENSION}"
  return nil unless File.file? file_path

  YAML.load_file file_path
end

def save_data(directory_names, file_name, data)
  directory_path = File.join DATA_PATH, *directory_names
  FileUtils.mkdir_p directory_path

  file_path = File.join directory_path, "#{file_name}#{DATA_EXTENSION}"
  File.write file_path, data.to_yml

  nil
end
