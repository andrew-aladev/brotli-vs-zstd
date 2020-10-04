#!/usr/bin/env ruby

require_relative "chart/main"
require_relative "common/params"

vendor = ARGV[0]
params = ARGV[1..-1]

raise StandardError, "vendor is required" if vendor.nil? || vendor.empty?

option_groups = parse_option_groups params
process_charts vendor, option_groups
