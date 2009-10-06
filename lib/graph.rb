require 'rubygems'
require 'nokogiri'
require 'gruff'
require 'date'

class Sample
  attr_accessor :time, :kwh

  def initialize(time, kwh)
    @time = time
    @kwh = kwh
  end

  def inspect
    "<Sample #{@time} #{@kwh}>"
  end
end

data = File.read('dump2.html')
document = Nokogiri::HTML(data)
nodes = document.css('noscript area').to_a.reverse

# difficult to tell if this information is in UTC or not.
hour_increment = 1/24.0 
timestamp = DateTime.new(2009,9,27,0,0,0) - hour_increment + 1/(24.0*60)

samples = nodes.map do |n|
  kwh = n['alt'].to_f
  timestamp = timestamp + hour_increment
  Sample.new(timestamp, kwh)
end

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
