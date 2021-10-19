require_relative "../file/data"
require_relative "build"

PERFORMANCE_SCALE   = 1 << 20
PERFORMANCE_POSTFIX = "MB/s".freeze

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
    :postfix    => PERFORMANCE_POSTFIX,
    :value_keys => {
      "compress" => %i[total compress_performance]
    }
  },
  {
    :name       => "total decompress performance",
    :scale      => PERFORMANCE_SCALE,
    :postfix    => PERFORMANCE_POSTFIX,
    :value_keys => {
      "decompress" => %i[total decompress_performance]
    }
  },
  {
    :name       => "ratio limits",
    :value_keys => {
      "max" => %i[single ratio max],
      "min" => %i[single ratio min]
    }
  },
  {
    :name       => "compress performance limits",
    :scale      => PERFORMANCE_SCALE,
    :postfix    => PERFORMANCE_POSTFIX,
    :value_keys => {
      "max" => %i[single compress_performance max],
      "min" => %i[single compress_performance min]
    }
  },
  {
    :name       => "decompress performance limits",
    :scale      => PERFORMANCE_SCALE,
    :postfix    => PERFORMANCE_POSTFIX,
    :value_keys => {
      "max" => %i[single decompress_performance max],
      "min" => %i[single decompress_performance min]
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
    :postfix    => PERFORMANCE_POSTFIX,
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
    :postfix    => PERFORMANCE_POSTFIX,
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
  option_groups.each.with_index do |options, index|
    extension = options[:extension]
    type      = options[:type]

    data = load_files_data vendor, extension, type
    if data.nil?
      warn "data for vendor: #{vendor}, extension: #{extension}, type: #{type} is not found"
      next
    end

    brotli_version = data[:brotli_version]
    zstds_version  = data[:zstds_version]
    stats_datas    = data[:stats_datas]

    percent = format_percent index, option_groups.length
    warn "- #{percent}% processing charts, vendor: #{vendor}, extension: #{extension}, type: #{type}"

    CHART_DECLARATIONS.each.with_index do |declaration, declaration_index|
      name = declaration[:name]

      declaration_percent = format_percent declaration_index, CHART_DECLARATIONS.length
      warn "#{declaration_percent}% processing chart, name: #{name}"

      stats_datas.each do |stats_data|
        build_chart vendor, extension, type, brotli_version, zstds_version, stats_data, declaration
      end
    end
  end

  nil
end
