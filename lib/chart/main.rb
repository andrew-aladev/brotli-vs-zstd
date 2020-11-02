#!/usr/bin/env ruby

require_relative "../common/params"
require_relative "process"

vendor = ARGV[0]
params = ARGV[1..-1]

raise StandardError, "vendor is required" if vendor.nil? || vendor.empty?

option_groups = parse_params params
process_charts vendor, option_groups
