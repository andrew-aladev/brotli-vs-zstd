require "colorize"

def colorize_length(length)
  length.zero? ? "0" : length.to_s.light_green
end
