# Used only to launch from a jar using rawr

require 'jruby'
# This is needed for nokogiri to function properly under jruby
JRuby.objectspace=true

require 'smartermeter'
require 'smartermeter/daemon'
require 'smartermeter/interfaces/swing'

interface = SmarterMeter::Interfaces::Swing.new
SmarterMeter::Daemon.new(interface).start
