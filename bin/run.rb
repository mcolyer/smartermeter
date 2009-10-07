require 'rubygems'
Gem.clear_paths
ENV['GEM_HOME'] = File.join(File.dirname(__FILE__), '..', 'gems')

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'smartermeter'
require 'date'

USERNAME = $ARGV[0]
PASSWORD = $ARGV[1]

api = SmartMeterService.new
api.login(USERNAME, PASSWORD)
yesterday = Date.today - 1
samples = api.fetch_day(yesterday)
puts samples.inspect
