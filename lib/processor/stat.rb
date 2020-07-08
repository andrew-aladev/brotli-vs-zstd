require "descriptive_statistics"

STAT_METHODS = %i[
  min
  max
  mode
  median
  mean
  standard_deviation
]
.freeze

def get_efficiency_from_result(result)
  content_size            = result[:content_size]
  compressed_content_size = result[:compressed_content_size]
  compress_time           = result[:compress_time]
  decompress_time         = result[:decompress_time]

  {
    :ratio                  => content_size.to_f / compressed_content_size,
    :compress_performance   => content_size.to_f / compress_time,
    :decompress_performance => compressed_content_size.to_f / decompress_time
  }
end

def get_efficiencies_from_results(results)
  results.map { |result| get_efficiency_from_result result }
end

def get_stats_from_efficiencies(efficiencies)
  efficiencies.keys.each_with_object({}) do |key, stat_groups|
    values = efficiencies.map { |efficiency| efficiency[key] }

    stat_groups[key] = STAT_METHODS.each_with_object({}) do |stat_method, stats|
      stats[stat_method] = values.send stat_method
    end
  end
end

def get_stat_data_from_result_data(total_result, results)
  {
    :total => get_efficiency_from_result(total_result),
    :stats => get_stats_from_efficiencies(get_efficiencies_from_results(results))
  }
end
