#!/usr/bin/env ruby

require_relative "../common/compress"
require_relative "../common/format"
require_relative "../common/script"

pathes = get_script_pathes :minified_only

puts "-- Brotli:"

stats = get_script_stats pathes, method(:brotli_compress_max_level), method(:brotli_decompress)

puts "- ratio:"
data = stats.map { |stat| stat[:ratio] }
pp get_descriptive_statistics(data)

puts "- compressed time:"
data = stats.map { |stat| stat[:compressed_time] }
pp get_descriptive_statistics(data)

puts "- decompressed time:"
data = stats.map { |stat| stat[:decompressed_time] }
pp get_descriptive_statistics(data)

puts "-- Zstd:"

stats = get_script_stats pathes, method(:zstd_compress_max_level), method(:zstd_decompress)

puts "- ratio:"
data = stats.map { |stat| stat[:ratio] }
pp get_descriptive_statistics(data)

puts "- compressed time:"
data = stats.map { |stat| stat[:compressed_time] }
pp get_descriptive_statistics(data)

puts "- decompressed time:"
data = stats.map { |stat| stat[:decompressed_time] }
pp get_descriptive_statistics(data)
