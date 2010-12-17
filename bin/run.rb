require 'rubygems'
Gem.clear_paths
ENV['GEM_HOME'] = File.join(File.dirname(__FILE__), '..', 'gems')

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'smartermeter'
require 'date'

USERNAME = $ARGV[0]
PASSWORD = $ARGV[1]
if $ARGV.length > 2
  DATE = Date.parse($ARGV[2])

  if $ARGV[3]
    ENDDATE = Date.parse($ARGV[3])
  else
    ENDDATE = DATE;
  end

else
  DATE = Date.today - 2
  ENDDATE = DATE;
end

api = SmartMeterService.new
api.login(USERNAME, PASSWORD)

if DATE > ENDDATE
  DATE.downto(ENDDATE) do |date|
    printf "### %s\n", date
    print api.fetch_csv(date)
  end
else
  DATE.upto(ENDDATE) do |date|
    printf "### %s\n", date
    print api.fetch_csv(date)
  end
end
