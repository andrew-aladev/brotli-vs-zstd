#!/usr/bin/env ruby

require_relative "file/find"

name      = ARGV[0]
root_path = ARGV[1]
params    = ARGV[2..]

raise StandardError, "name argument is required" if name.nil? || name.empty?
raise StandardError, "root path is required" if root_path.nil? || root_path.empty?
raise StandardError, "params are required" if params.empty?

option_groups = params.flat_map do |param|
  data = param.split ":"
  raise StandardError, "param: postfix : types" if data.length != 2

  postfix = data[0]
  raise StandardError, "postfix is required" if postfix.nil? || postfix.empty?

  types_value = data[1]
  raise StandardError, "types value is required" if types_value.nil? || types_value.empty?

  types = types_value.split ","
  raise StandardError, "types are required" if types.empty?

  types.map do |type|
    {
      :postfix => postfix,
      :type    => type.to_sym
    }
  end
end

option_groups.each do |options|
  file_pathes = find_file_pathes root_path, options[:postfix], options[:type]
  pp file_pathes
end
