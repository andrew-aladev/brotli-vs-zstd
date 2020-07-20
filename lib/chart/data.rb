require "gruff"

CHART_PATH      = File.join(File.dirname(__FILE__), "..", "..", "chart").freeze
CHART_EXTENSION = ".png".freeze

def save_chart(directory_names, file_name, chart)
  directory_path = File.join CHART_PATH, *directory_names
  FileUtils.mkdir_p directory_path

  full_file_name = file_name + CHART_EXTENSION
  file_path      = File.join directory_path, full_file_name
  chart.write file_path

  nil
end
