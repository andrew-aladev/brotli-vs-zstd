require_relative "data"
require_relative "params"

def get_processor_results(pathes)
  params_combinations = get_processor_params_combinations

  processor_datas = params_combinations.map do |params|
    type              = params[:type]
    compression_level = params[:compression_level]

    {
      :compressor_data   => create_compressor_data(type, compression_level),
      :decompressor_data => create_decompressor_data(type)
    }
  end

  begin
    params_combinations.each.with_index do |params, index|
      type              = params[:type]
      compression_level = params[:compression_level]
      processor_data    = processor_datas[index]
    end

  ensure
    processor_datas.each do |processor_data|
      close_processor_data processor_data[:compressor_data]
      close_processor_data processor_data[:decompressor_data]
    end
  end

  {}
end
