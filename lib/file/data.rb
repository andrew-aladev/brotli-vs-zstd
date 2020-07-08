require_relative "../common/data"

def load_files_data(vendor, extension, type)
  load_data [vendor, extension], type.to_s
end

def save_files_data(vendor, extension, type, data)
  save_data [vendor, extension], type.to_s, data
end
