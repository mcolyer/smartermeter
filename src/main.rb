require 'rubygems'
Gem.clear_paths
ENV['GEM_HOME'] = File.join(File.dirname(__FILE__), '..', 'gems')

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'smartermeter'
require 'date'

USERNAME = $ARGV[0]
PASSWORD = $ARGV[1]
if $ARGV.length > 2
  date_re = /([0-9]{1,2})\/([0-9]{1,2})\/([0-9]{4})/
  if not date_re.match($ARGV[2])
    puts "The date must be MM/DD/YYYY"
    exit -1
  end

  month, day, year = date_re.match($ARGV[2]).captures
  month = month.to_i
  day = day.to_i
  year = year.to_i

  DATE = Date.new(year, month, day)
else
  DATE = Date.today - 2
end

api = SmartMeterService.new
api.login(USERNAME, PASSWORD)
print api.fetch_csv(DATE)
