#!/usr/bin/env ruby

require_relative "../common/compress"
require_relative "../common/format"
require_relative "../common/script"

pathes = get_script_pathes :not_minified_only

puts "-- Brotli:"

stat = get_all_scripts_stat pathes, method(:brotli_create_compressor_max_level), method(:brotli_create_decompressor)
pp stat

puts "-- Zstd:"

stat = get_all_scripts_stat pathes, method(:zstd_create_compressor_max_level), method(:zstd_create_decompressor)
pp stat
