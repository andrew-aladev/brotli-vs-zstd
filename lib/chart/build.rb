require "gruff"

require_relative "../common/format"
require_relative "data"

TYPE_TITLES = {
  :not_min => "not minified",
  :min     => "minified",
  :any     => ""
}
.freeze

CHART_SIZE    = "600x1800".freeze
CHART_OPTIONS = {
  :font             => File.join(File.dirname(__FILE__), "..", "..", "fonts", "RobotoMono.ttf"),
  :title_font_size  => 20.0,
  :legend_font_size => 16.0,
  :marker_font_size => 14.0,
  :minimum_value    => 0.0
}
.freeze

def build_chart(vendor, extension, type, stats_data, declaration)
  from_size  = stats_data[:from_size]
  to_size    = stats_data[:to_size]
  count      = stats_data[:count]
  stats      = stats_data[:stats]
  name       = declaration[:name]
  scale      = declaration[:scale]
  postfix    = declaration[:postfix]
  value_keys = declaration[:value_keys]

  type_title = TYPE_TITLES[type]
  raise StandardError, "received invalid type: #{type}" if type_title.nil?

  extension_title =
    if type_title.empty?
      extension
    else
      "#{type_title} #{extension}"
    end

  from_size = format_filesize from_size, 0 unless from_size.nil?
  to_size   = format_filesize to_size, 0 unless to_size.nil?

  title = "#{name.capitalize} for #{count} #{extension_title} files from #{vendor.tr('_', ' ')}"
  title += ", size: #{from_size} - #{to_size}" unless from_size.nil? || to_size.nil?
  title += " (#{postfix})" unless postfix.nil?

  labels = stats.map do |stat|
    processor_type    = stat[:type]
    compression_level = stat[:compression_level]

    label =
      case processor_type
      when :brotli
        "br"
      when :zstd
        "zst"
      else
        raise StandardError, "received invalid processor type: #{processor_type}"
      end

    "#{label} #{format_compression_level(compression_level)}"
  end

  chart        = Gruff::SideBar.new CHART_SIZE
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

  CHART_OPTIONS.each { |key, value| chart.send "#{key}=", value }

  file_name =
    if from_size.nil? || to_size.nil?
      "all"
    else
      "#{from_size} - #{to_size}"
    end

  save_chart [vendor, extension, type.to_s, name.tr(" ", "_")], file_name, chart
end
