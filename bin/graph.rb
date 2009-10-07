require 'rubygems'
Gem.path << File.join(File.dirname(__FILE__), '..', 'gems')
require 'gruff'

require 'date'
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'smartermeter'

USERNAME = $ARGV[0]
PASSWORD = $ARGV[1]

api = SmartMeterService.new
api.login(USERNAME, PASSWORD)
yesterday = Date.today - 1
samples = api.fetch_day(yesterday)

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
g.write('power.png')
