require "brs"
require "zstds"

PROCESSOR_TYPES = %i[brotli zstd].freeze

COMPRESSION_LEVELS = {
  :brotli => BRS::Option::MIN_QUALITY..BRS::Option::MAX_QUALITY,
  :zstd   => 1..ZSTDS::Option::MAX_COMPRESSION_LEVEL
}
.freeze

def get_processor_params_combinations
  PROCESSOR_TYPES.flat_map do |type|
    COMPRESSION_LEVELS[type].map do |compression_level|
      {
        :type              => type,
        :compression_level => compression_level
      }
    end
  end
end
