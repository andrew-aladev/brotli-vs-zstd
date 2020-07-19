require "filesize"

FORMAT_PERCENT_ROUND_LENGTH = 2

def format_percent(index, length)
  max_index = length - 1
  return "100.00" if max_index.zero?

  percent = index.to_f * 100 / max_index
  format(
    "%.#{FORMAT_PERCENT_ROUND_LENGTH}f",
    percent.round(FORMAT_PERCENT_ROUND_LENGTH)
  )
end

def format_filesize(size)
  Filesize.new(size).pretty
end
