module SmarterMeter
  module Transports
    # For now this class is a simple wrapper on top of pge2google.py
    class GooglePowerMeter
      def initialize(config)
        @config = config
        raise "The pge2google path must be configured" unless @config[:path]
        raise "The pge2google token must be configured" unless @config[:token]
        raise "The pge2google variable must be configured" unless @config[:variable]
      end

      # Uploads the PG&E formatted CSV file
      #
      # file - The absolute file path to upload
      #
      # Returns nothing
      def upload(file)
        `python #{@config[:path]} --token #{@config[:token]} --variable #{@config[:variable]} #{file}`
      end
    end
  end
end
