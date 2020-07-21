require "gruff"

require_relative "../common/format"
require_relative "data"

TYPE_LABELS = {
  :not_min => "not minified",
  :min     => "minified",
  :any     => ""
}
.freeze

def build_chart(vendor, extension, type, stats_data, declaration)
  from_size  = stats_data[:from_size]
  to_size    = stats_data[:to_size]
  count      = stats_data[:count]
  stats      = stats_data[:stats]
  name       = declaration[:name]
  scale      = declaration[:scale]
  value_keys = declaration[:value_keys]

  type_label = TYPE_LABELS[type]
  raise StandardError, "received invalid type: #{type}" if type_label.nil?

  extension = "#{type_label} #{extension}" unless type_label.empty?
  from_size = format_filesize from_size, 0 unless from_size.nil?
  to_size   = format_filesize to_size, 0 unless to_size.nil?

  title = "#{name.capitalize} for #{count} #{extension} files from #{vendor.sub('_', ' ')}"
  title += ", size: #{from_size} - #{to_size}" unless from_size.nil? || to_size.nil?

  labels = stats.map do |stat|
    processor_type    = stat[:type]
    compression_level = stat[:compression_level]

    label =
      case processor_type
      when :brotli
        "b"
      when :zstd
        "z"
      else
        raise StandardError, "received invalid processor type: #{processor_type}"
      end

    "#{label}/#{compression_level}"
  end

  chart        = Gruff::SideBar.new
  chart.title  = title
  chart.labels = labels.each_with_object({})
    .with_index { |(label, result), index| result[index] = label }

  value_keys.each do |keys_name, keys|
    data = stats.map do |stat|
      value = stat.dig(*keys)

      if scale.nil?
        value
      else
        value.to_f / scale
      end
    end

    chart.data keys_name, data
  end

  file_name =
    if from_size.nil? || to_size.nil?
      "all"
    else
      "#{from_size} - #{to_size}"
    end

  save_chart [vendor, extension, type.to_s, name.sub(" ", "_")], file_name, chart
end
