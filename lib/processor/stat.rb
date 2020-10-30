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

  ratio =
    if !compressed_content_size.zero?
      content_size.to_f / compressed_content_size
    else
      0
    end

  compress_performance =
    if !compress_time.zero?
      content_size.to_f / compress_time
    else
      0
    end

  decompress_performance =
    if !decompress_time.zero?
      compressed_content_size.to_f / decompress_time
    else
      0
    end

  {
    :ratio                  => ratio,
    :compress_performance   => compress_performance,
    :decompress_performance => decompress_performance
  }
end

def get_efficiencies_from_results(results)
  results.map { |result| get_efficiency_from_result result }
end

def get_stats_from_efficiencies(efficiencies)
  first_efficiency = efficiencies.first
  return {} if first_efficiency.nil?

  first_efficiency.keys.each_with_object({}) do |key, stat_groups|
    values = efficiencies.map { |efficiency| efficiency[key] }

    stat_groups[key] = STAT_METHODS.each_with_object({}) do |stat_method, stats|
      stats[stat_method] = values.send stat_method
    end
  end
end

def get_stats_from_results(total_result, single_results)
  {
    :total  => get_efficiency_from_result(total_result),
    :single => get_stats_from_efficiencies(get_efficiencies_from_results(single_results))
  }
end
