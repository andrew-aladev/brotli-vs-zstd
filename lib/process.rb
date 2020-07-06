#!/usr/bin/env ruby

require_relative "file/main"

vendor    = ARGV[0]
root_path = ARGV[1]
params    = ARGV[2..]

raise StandardError, "vendor is required" if vendor.nil? || vendor.empty?
raise StandardError, "root path is required" if root_path.nil? || root_path.empty?
raise StandardError, "at least one param is required" if params.empty?

option_groups = params.flat_map do |param|
  data = param.split ":"
  raise StandardError, "invalid param format, required format: 'postfix:types'" if data.length != 2

  postfix = data[0]
  raise StandardError, "postfix is required" if postfix.nil? || postfix.empty?

  types_value = data[1]
  raise StandardError, "types value is required" if types_value.nil? || types_value.empty?

  types = types_value.split ","
  raise StandardError, "at least one type is required" if types.empty?

  types.map do |type|
    {
      :postfix => postfix,
      :type    => type.to_sym
    }
  end
end

process_files vendor, root_path, option_groups
