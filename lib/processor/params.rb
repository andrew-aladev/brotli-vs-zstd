require "brs"
require "zstds"

PROCESSOR_TYPES = %i[brotli zstd].freeze

COMPRESSION_LEVELS = {
  :brotli => BRS::Option::MIN_QUALITY..BRS::Option::MAX_QUALITY,
  :zstd   => 1..ZSTDS::Option::MAX_COMPRESSION_LEVEL
}
.freeze

# Test will be executed in single thread.
# We need to enable gvl, it will provides more accurate result.
# Ruby won't waste time on acquiring/releasing VM lock.

def get_processor_params_combinations
  PROCESSOR_TYPES.flat_map do |type|
    COMPRESSION_LEVELS[type].map do |compression_level|
      {
        :type              => type,
        :compression_level => compression_level,
        :gvl               => true
      }
    end
  end
end
