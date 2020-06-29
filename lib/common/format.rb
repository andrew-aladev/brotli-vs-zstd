require "filesize"

FORMAT_PERCENT_ROUND_LENGTH = 2
FORMAT_FLOAT_ROUND_LENGTH   = 5

def format_percent(index, length)
  max_index = length - 1
  return 100 if max_index.zero?

  (index.to_f * 100 / max_index)
    .round(FORMAT_PERCENT_ROUND_LENGTH)
    .to_s
end

def format_float(value)
  format(
    "%.#{FORMAT_FLOAT_ROUND_LENGTH}f",
    value.round(FORMAT_FLOAT_ROUND_LENGTH)
  )
end

def format_filesize(size)
  Filesize.new(size).pretty
end

# require "descriptive_statistics"

# def get_descriptive_statistics(object)
#   object.descriptive_statistics
#     .dup.tap { |stats| stats.delete :number }
#     .transform_values do |value|
#       next nil if value.nil?
#
#       float_to_string value
#     end
# end
