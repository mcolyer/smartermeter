require 'logger'

module SmarterMeter
  module Interfaces
    class CLI
      def initialize(options)
        @options = options
      end

      # Returns a logger like interface to log errors and warnings to.
      def log
        return @logger if @logger
        @logger = Logger.new STDOUT

        if @options[:debug]
          @logger.level = Logger::DEBUG
        else
          @logger.level = Logger::INFO
        end

        @logger
      end

      # Public: Called when ~/.smartermeter needs to be configured.
      # Yields a hash containing the configuration by the user.
      #
      # Returns nothing
      def setup
        puts
        puts "SmarterMeter: Initial Configuration"
        puts "--------------------------------------------------------------------------------"
        puts "This program stores your PG&E account username and password on disk. The"
        puts "password is encrypted but could be retrieved fairly easily. If this makes you"
        puts "uncomfortable quit now (use ctrl-c)."
        puts "--------------------------------------------------------------------------------"

        config = {}

        print "PG&E account username: "
        config[:username] = gets.strip

        print "PG&E account password: "
        config[:password] = gets.strip

        puts "Configuration finished"

        yield config
      end
    end
  end
end
