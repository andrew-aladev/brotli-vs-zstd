def parse_params(params)
  raise StandardError, "at least one param is required" if params.empty?

  params.flat_map do |param|
    data = param.split ":"
    raise StandardError, "invalid param format, required format: 'extension:types'" unless data.length == 2

    extension = data[0]
    raise StandardError, "extension is required" if extension.nil? || extension.empty?

    types_value = data[1]
    raise StandardError, "types value is required" if types_value.nil? || types_value.empty?

    types = types_value.split ","
    raise StandardError, "at least one type is required" if types.empty?

    types.map do |type|
      {
        :extension => extension,
        :type      => type.to_sym
      }
    end
  end
end
