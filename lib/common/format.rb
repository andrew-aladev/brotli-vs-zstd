require "filesize"

FORMAT_PERCENT_ROUND_LENGTH = 2

def format_percent(index, length)
  return "100.00" if length <= 1

  percent = index.to_f * 100 / (length - 1)
  format(
    "%.#{FORMAT_PERCENT_ROUND_LENGTH}f",
    percent.round(FORMAT_PERCENT_ROUND_LENGTH)
  )
end

def format_filesize(size)
  Filesize.new(size).pretty
end
