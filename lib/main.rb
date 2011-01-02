require 'rubygems'
require 'yaml'
require 'jruby'
require 'logger'
require 'date'

# This is needed for nokogiri to function properly under jruby
JRuby.objectspace=true

$:.unshift File.join(File.dirname(__FILE__))
require 'service'
require 'sample'
require 'date'

class Daemon

  # Loads the configuration, and starts the daemon.
  #
  # Never returns.
  def start
    configure
    daemonize
    run
  end

protected
  def log_file
    File.join(File.dirname(__FILE__), "..", "smartermeter.log")
  end

  def config_file
    File.expand_path("~/.smartermeter")
  end

  def default_data_dir
    File.join(File.dirname(__FILE__), "..", "data")
  end

  # Returns a filename for the data belonging to the given date.
  def data_file(date)
    File.join(@config[:data_dir], date.strftime("%Y-%m-%d.csv"))
  end

  def log
    @logger = Logger.new STDOUT
    @logger.level = Logger::INFO
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
      :start_date => Date.today,
      :data_dir => default_data_dir
    }

    if File.exist?(config_file)
      @config = YAML.load_file(config_file)
    end

    @config
  end

  # Takes the unencrypted password and encrypts it.
  def password=(unencrypted)
    #TODO: actually encrypt this password
    @config[:password] = unencrypted
  end

  # Returns the clear-text password or nil if it isn't set.
  def password
    @config.fetch(:password, nil)
  end

  # Prompts the user for required settings that are blank.
  #
  # Returns nothing.
  def verify_configuration
    return if @config[:username] and @config[:password]

    puts
    puts "Smartermeter: Initial Configuration"
    puts "--------------------------------------------------------------------------------"
    puts "This program stores your PG&E account username and password on disk. The"
    puts "password is encrypted but could be retrieved fairly easily. If this makes you"
    puts "uncomfortable quit now (use ctrl-c)."
    puts "--------------------------------------------------------------------------------"

    unless @config[:username]
      print "PG&E account username (typically your email address): "
      @config[:username] = gets.strip
    end

    unless @config[:password]
      print "PG&E account password: "
      self.password = gets.strip
    end

    save_configuration
    puts "Setup complete"
  end

  # Saves the current configuration to disk.
  #
  # Returns nothing.
  def save_configuration
    File.open(config_file, "w") do |file|
      file.write(YAML.dump(@config))
    end
  end

  # Performs the necessary steps to daemonize this process.
  def daemonize
    #TODO: Actually daemonize this process
  end

  # Continually checks for new data for any missing days, since the first day
  # smartermeter started watching.
  #
  # Never returns.
  def run
    one_hour = 60 * 60

    while true
      dates = dates_requiring_data
      log.info("Attempting to fetch data for: #{dates.inspect}")
      results = fetch_dates(dates)
      log.info("Successfully fetched: #{results.inspect}")
      sleep(one_hour)
    end
  end

  def api
    @api ||= SmartMeterService.new
    @api.login(@config[:username], @config[:password])
  end

  # Connect and authenticate to the PG&E Website.
  #
  # It provides an instance of SmartMeterService to the provided block
  # for direct manipulation.
  #
  # Returns nothing.
  def connect
    begin
      yield api
    rescue SocketError => e
      log.error("Could not access the PG&E site, are you connected to the Internet?")
    rescue Exception => e
      log.error(e)
    end
  end

  # Attempts to retrieve power data for each of the dates in the list.
  #
  # dates - An array of Date objects to retrieve power data for.
  #
  # Returns an Array of successfully retrieved dates.
  def fetch_dates(dates)
    completed = []

    connect do |api|
      dates.each do |date|
        data = api.fetch_csv(date)
        File.open(data_file(date), "w") do |f|
          f.write(data)
        end
        completed << date
      end
    end
  end

  # Returns an Array of Date objects containing all dates since start_date
  # missing power data.
  def dates_requiring_data
    [Date.today]
  end
end

if __FILE__ == $0
  Daemon.new.start
end
