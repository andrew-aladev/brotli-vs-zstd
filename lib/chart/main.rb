require_relative "../file/data"
require_relative "build"

PERFORMANCE_SCALE = 1 << 20 # MB/s

CHART_DECLARATIONS = [
  {
    :name       => "total ratio",
    :value_keys => {
      "ratio" => %i[total ratio]
    }
  },
  {
    :name       => "total compress performance",
    :scale      => PERFORMANCE_SCALE,
    :value_keys => {
      "compress" => %i[total compress_performance]
    }
  },
  {
    :name       => "total decompress performance",
    :scale      => PERFORMANCE_SCALE,
    :value_keys => {
      "decompress" => %i[total decompress_performance]
    }
  },
  {
    :name       => "ratio limits",
    :value_keys => {
      "min" => %i[single ratio min],
      "max" => %i[single ratio max]
    }
  },
  {
    :name       => "compress performance limits",
    :scale      => PERFORMANCE_SCALE,
    :value_keys => {
      "min" => %i[single compress_performance min],
      "max" => %i[single compress_performance max]
    }
  },
  {
    :name       => "decompress performance limits",
    :scale      => PERFORMANCE_SCALE,
    :value_keys => {
      "min" => %i[single decompress_performance min],
      "max" => %i[single decompress_performance max]
    }
  },
  {
    :name       => "ratio",
    :value_keys => {
      "mode"               => %i[single ratio mode],
      "median"             => %i[single ratio median],
      "mean"               => %i[single ratio mean],
      "standard deviation" => %i[single ratio standard_deviation]
    }
  },
  {
    :name       => "compress performance",
    :scale      => PERFORMANCE_SCALE,
    :value_keys => {
      "mode"               => %i[single compress_performance mode],
      "median"             => %i[single compress_performance median],
      "mean"               => %i[single compress_performance mean],
      "standard deviation" => %i[single compress_performance standard_deviation]
    }
  },
  {
    :name       => "decompress performance",
    :scale      => PERFORMANCE_SCALE,
    :value_keys => {
      "mode"               => %i[single decompress_performance mode],
      "median"             => %i[single decompress_performance median],
      "mean"               => %i[single decompress_performance mean],
      "standard deviation" => %i[single decompress_performance standard_deviation]
    }
  }
]
.freeze

def process_charts(vendor, option_groups)
  warn "-- processing charts, vendor: #{vendor}"

  option_groups.each do |options|
    extension = options[:extension]
    type      = options[:type]

    data = load_files_data vendor, extension, type
    if data.nil?
      warn "data for vendor: #{vendor}, extension: #{extension}, type: #{type} is not found"
      next
    end

    data.each do |stats_data|
      CHART_DECLARATIONS.each do |declaration|
        build_chart vendor, extension, type, stats_data, declaration
      end
    end
  end

  nil
end
