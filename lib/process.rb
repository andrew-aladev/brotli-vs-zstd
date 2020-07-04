#!/usr/bin/env ruby

require "ocg"

name         = ARGV[0]
root_path    = ARGV[1]
descriptions = ARGV[2..]

raise StandardError, "name argument is required" if name.nil? || name.empty?
raise StandardError, "root path is required" if root_path.nil? || root_path.empty?
raise StandardError, "descriptions are required" if descriptions.empty?

datas = descriptions.flat_map do |description|
  data = description.split ":"
  raise StandardError, "description: postfix : types" if data.length != 2

  postfix = data[0]
  raise StandardError, "description postfix is required" if postfix.nil? || postfix.empty?

  types_value = data[1]
  raise StandardError, "description types value is required" if types_value.nil? || types_value.empty?

  types = types_value.split ","
  raise StandardError, "description types are required" if types.empty?

  types.map do |type|
    {
      :postfix => postfix,
      :type    => type.to_sym
    }
  end
end

pp datas

# postfixes = postfixes.split(",").freeze
# types     = types.split(",").map(&:to_sym).freeze

# pp postfixes
# pp types
