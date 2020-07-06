require "brs"
require "ocg"
require "zstds"

PROCESSOR_TYPES = %i[brotli zstd].freeze

COMPRESSION_LEVELS = {
  :brotli => BRS::Option::MIN_QUALITY..BRS::Option::MAX_QUALITY,
  :zstd   => 0..ZSTDS::Option::MAX_COMPRESSION_LEVEL
}
.freeze

def get_processor_params_combinations
  generator = nil

  PROCESSOR_TYPES.each do |type|
    current_generator = OCG.new(
      :type              => [type],
      :compression_level => COMPRESSION_LEVELS[type]
    )

    generator =
      if generator.nil?
        current_generator
      else
        generator.or current_generator
      end
  end

  generator.to_a
end
