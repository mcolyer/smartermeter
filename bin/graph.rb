require 'rubygems'
Gem.clear_paths
ENV['GEM_HOME'] = File.join(File.dirname(__FILE__), '..', 'gems')
require 'gruff'

require 'date'
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'smartermeter'

if $ARGV.length == 0
  puts "Usage: graph.rb USERNAME PASSWORD (desired date MM/DD/YYYY)"
  exit(0)
end

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
  DATE = Date.today - 1
end

api = SmartMeterService.new
api.login(USERNAME, PASSWORD)
samples = api.fetch_day(DATE)

g = Gruff::Line.new
g.hide_dots = true
g.title = "Power Usage" 
g.y_axis_label = "KW/H"
g.data("House", samples.map{|s| s.kwh})

i = -24
labels = []

samples.each_slice(24) do |s|
  i+=24
  labels << [i, s.first.time.strftime("%m-%d")]
  labels << [i+13, s[12].time.strftime("%H:%M")] if s[12]
end

g.labels = Hash[labels]
g.theme_pastel()
g.write("#{DATE.strftime("%m-%d-%Y")}.png")
