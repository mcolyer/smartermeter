require 'rubygems'
require 'lib/fetch'
require 'date'

USERNAME = $ARGV[0]
PASSWORD = $ARGV[1]

api = SmartMeterService.new
api.login(USERNAME, PASSWORD)
samples = api.fetch_day(Date.new(2009,9,25))
puts samples.inspect
