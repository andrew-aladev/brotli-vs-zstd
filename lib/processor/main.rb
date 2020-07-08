require_relative "data"
require_relative "params"

def get_processor_data(pathes)
  params_combinations = get_processor_params_combinations
  pp params_combinations

  # compressor_datas   = params_combinations.map { |params| create_decompressor_data params[:type], params[:compression_level] }
  decompressor_datas = PROCESSOR_TYPES.each_with_object({}) do |type, data|
    data[type] = create_decompressor_data type
  end

  begin
    params_combinations.each do |params|
      type              = params[:type]
      compression_level = params[:compression_level]
    end

  ensure
    decompressor_datas.each_value do |decompressor, write_io, read_io|
      decompressor.close
      write_io.close
      read_io.close
    end
  end

  {}
end
