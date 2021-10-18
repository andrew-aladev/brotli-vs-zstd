require "brs"
require "gruff"
require "zstds"

require_relative "../common/format"
require_relative "data"

TYPE_TITLES = {
  :not_min => "not minified",
  :min     => "minified",
  :any     => ""
}
.freeze

CHART_VALUE_HEIGHT  = 10
CHART_GROUP_SPACING = 5
CHART_HEIGHT_OFFSET = 120
CHART_WIDTH         = 800

CHART_OPTIONS = {
  :font             => File.join(File.dirname(__FILE__), "..", "..", "font", "RobotoMono.ttf"),
  :title_font_size  => 14,
  :legend_font_size => 13,
  :marker_font_size => 12,
  :group_spacing    => CHART_GROUP_SPACING,
  :minimum_value    => 0
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
  title += ", #{from_size} - #{to_size}" unless from_size.nil? || to_size.nil?
  title += " (#{postfix})" unless postfix.nil?
  title += "\n"
  title += "brotli v#{BRS::LIBRARY_VERSION}, zstd v#{ZSTDS::LIBRARY_VERSION}"

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

    "#{label} #{format_compression_level(compression_level)}"
  end

  value_height = CHART_VALUE_HEIGHT * value_keys.length + CHART_GROUP_SPACING
  height       = stats_data[:stats].length * value_height + CHART_HEIGHT_OFFSET
  size         = "#{CHART_WIDTH}x#{height}"

  chart        = Gruff::SideBar.new size
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
