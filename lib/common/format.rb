require "colorize"
require "descriptive_statistics"

FORMAT_FLOAT_ROUND_LENGTH   = 5
FORMAT_PERCENT_ROUND_LENGTH = 2

def colorize_length(length)
  length.zero? ? "0" : length.to_s.light_green
end

def format_float(value)
  value.round FORMAT_FLOAT_ROUND_LENGTH
end

def float_to_string(value)
  format "%.#{FORMAT_FLOAT_ROUND_LENGTH}f", format_float(value)
end

def colorize_float(value)
  float_to_string(value).light_green
end

def format_percent(index, length)
  max_index = length - 1
  return 100 if max_index.zero?

  (index.to_f * 100 / max_index).round FORMAT_PERCENT_ROUND_LENGTH
end

def get_descriptive_statistics(object)
  object.descriptive_statistics
    .dup.tap { |stats| stats.delete :number }
    .transform_values do |value|
      next nil if value.nil?

      float_to_string value
    end
end
