require 'fileutils'
require 'crypt/blowfish'
require 'yaml'
require 'date'

module SmarterMeter
  class Daemon

    def initialize(interface)
      @ui = interface
    end

    # Loads the configuration, and starts
    #
    # Never returns.
    def start
      configure
      run
    end

  protected
    def config_file
      File.expand_path("~/.smartermeter")
    end

    def default_data_dir
      File.expand_path(File.join(File.dirname(__FILE__), "..", "data"))
    end

    # Returns a filename for the data belonging to the given date.
    def data_file(date)
      File.expand_path(File.join(@config[:data_dir], date.strftime("%Y-%m-%d.csv")))
    end

    # Loads the configuration and prompts for required settings if they are
    # missing.
    #
    # Returns nothing.
    def configure
      load_configuration
      verify_configuration
    end

    # Loads the configuration from disk.
    #
    # Returns the configuration hash.
    def load_configuration
      @config = {
        :start_date => Date.today - 1,
        :data_dir => default_data_dir
      }

      if File.exist?(config_file)
        @config = YAML.load_file(config_file)
      end

      @config
    end

    def cipher
      Crypt::Blowfish.new("Our easily discoverable key.")
    end

    # Takes the unencrypted password and encrypts it.
    def password=(unencrypted)
      @config[:password] = cipher.encrypt_block(unencrypted)
    end

    # Returns the clear-text password or nil if it isn't set.
    def password
      password = @config.fetch(:password, nil)
      if password
        cipher.decrypt_block(password)
      else
        password
      end
    end

    # Returns true if the all of the required configuration has been set.
    def has_configuration?
      @config[:username] and @config[:password]
    end

    # Prompts the user for required settings that are blank.
    #
    # Returns nothing.
    def verify_configuration
      return if has_configuration?

      @ui.setup do |config|
        @config.merge!(config)
        self.password = config[:password] if config.has_key? :password
        save_configuration
      end
    end

    # Saves the current configuration to disk.
    #
    # Returns nothing.
    def save_configuration
      File.open(config_file, "w") do |file|
        file.write(YAML.dump(@config))
      end
    end

    # Continually checks for new data for any missing days, since the first day
    # smartermeter started watching.
    #
    # Never returns.
    def run
      one_hour = 60 * 60

      while true
        unless has_configuration?
          @ui.log.info("Waiting for configuration")
          sleep(5)
          next
        end

        dates = dates_requiring_data
        unless dates.empty?
          @ui.log.info("Attempting to fetch data for: #{dates.join(",")}")
          results = fetch_dates(dates)
          @ui.log.info("Successfully fetched: #{results.join(",")}")
        else
          @ui.log.info("Sleeping")
        end
        sleep(one_hour)
      end
    end

    # Create an authorized Service instance.
    #
    # Note: An authorization failure will cause an exits, as it is a dire
    # condition.
    #
    # Returns a new Service instance which has been properly authorized.
    def service
      service = Service.new
      @ui.log.info("Logging in as #{@config[:username]}")
      unless service.login(@config[:username], password)
        @ui.log.error("Incorrect username or password given.")
        @ui.log.error("Please remove ~/.smartermeter and configure smartermeter again.")
        exit(-1)
      end
      @ui.log.info("Logged in as #{@config[:username]}")
      service
    end

    # Connect and authenticate to the PG&E Website.
    #
    # It provides an instance of Service to the provided block
    # for direct manipulation.
    #
    # Returns nothing.
    def connect
      s = service
      begin
        yield s
      rescue SocketError => e
        @ui.log.error("Could not access the PG&E site, are you connected to the Internet?")
      end
    end

    # Attempts to retrieve power data for each of the dates in the list.
    #
    # dates - An array of Date objects to retrieve power data for.
    #
    # Returns an Array of successfully retrieved dates.
    def fetch_dates(dates)
      completed = []

      connect do |service|
        dates.each do |date|
          @ui.log.info("Fetching #{date}")
          data = service.fetch_csv(date)

          @ui.log.info("Verifying #{date}")
          samples = Sample.parse_csv(data).values.first
          first_sample = samples.first

          if first_sample.kwh
            @ui.log.info("Saving #{date}")
            FileUtils.mkdir_p(File.dirname(data_file(date)))
            File.open(data_file(date), "w") do |f|
              f.write(data)
            end

            upload(date, samples)

            @ui.log.info("Completed #{date}")
            completed << date
          else
            @ui.log.info("Incomplete #{date}")
          end
        end
      end

      completed
    end

    def upload(date, samples)
      case @config[:transport]
      when :google_powermeter
        @ui.log.info("Uploading #{date} to Google PowerMeter")
        transport = SmarterMeter::Transports::GooglePowerMeter.new(@config[:google_powermeter])
        if transport.upload(samples)
          @ui.log.info("Upload for #{date} complete")
        else
          @ui.log.info("Upload for #{date} failed")
        end
      end
    end

    # Returns an Array of Date objects containing all dates since start_date
    # missing power data.
    def dates_requiring_data
      collected = Dir.glob(File.join(@config[:data_dir], "*-*-*.csv")).map { |f| File.basename(f, ".csv") }
      all_days = []

      count_of_days = (Date.today - @config[:start_date]).to_i

      count_of_days.times do |i|
        all_days << (@config[:start_date] + i).strftime("%Y-%m-%d")
      end

      (all_days - collected).map { |d| Date.parse(d) }
    end
  end
end
