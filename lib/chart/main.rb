require_relative "../file/data"
require_relative "data"

CHART_DECLARATIONS = [
  {
    :name => "total",
    :keys => {
      "ratio" => %i[total ratio]
    }
  },
  {
    :name => "total compress performance",
    :keys => {
      "compress"   => %i[total compress_performance],
      "decompress" => %i[total decompress_performance]
    }
  },
  {
    :name => "total performance",
    :keys => {
      "compress"   => %i[total compress_performance],
      "decompress" => %i[total decompress_performance]
    }
  },
  {
    :name => "ratio limits",
    :keys => {
      "min" => %i[single ratio min],
      "max" => %i[single ratio max]
    }
  },
  {
    :name => "compress performance limits",
    :keys => {
      "compress min" => %i[single compress_performance min],
      "compress max" => %i[single compress_performance max]
    }
  },
  {
    :name => "decompress performance limits",
    :keys => {
      "min" => %i[single decompress_performance min],
      "max" => %i[single decompress_performance max]
    }
  },
  {
    :name => "ratio",
    :keys => {
      "mode"               => %i[single ratio mode],
      "median"             => %i[single ratio median],
      "mean"               => %i[single ratio mean],
      "standard deviation" => %i[single ratio standard_deviation]
    }
  },
  {
    :name => "compress performance",
    :keys => {
      "mode"               => %i[single compress_performance mode],
      "median"             => %i[single compress_performance median],
      "mean"               => %i[single compress_performance mean],
      "standard deviation" => %i[single compress_performance standard_deviation]
    }
  },
  {
    :name => "decompress performance",
    :keys => {
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
        build_chart vendor, extension, type, stats_data, declaration[:name], declaration[:keys]
      end
    end
  end

  nil
end
