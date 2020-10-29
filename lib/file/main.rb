#!/usr/bin/env ruby

require_relative "../common/params"

vendor    = ARGV[0]
root_path = ARGV[1]
params    = ARGV[2..-1]

raise StandardError, "vendor is required" if vendor.nil? || vendor.empty?
raise StandardError, "root path is required" if root_path.nil? || root_path.empty?

option_groups = parse_params params
# process_files vendor, root_path, option_groups
