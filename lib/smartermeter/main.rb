# Used only to launch from a jar using rawr

require 'jruby'
# This is needed for nokogiri to function properly under jruby
JRuby.objectspace=true

require 'smartermeter'

SmarterMeter::Daemon.new.start
