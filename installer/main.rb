# Used only to launch from a jar using rawr

require 'rubygems'
require 'jruby'
# This is needed for nokogiri to function properly under jruby
JRuby.objectspace=true

require 'smartermeter'
require 'smartermeter/daemon'
require 'smartermeter/interfaces/swing'

# Force character sets of all retrieved documents so that we don't have to have
# charsets.jar in the JRE
class Mechanize
  class Util
    def self.detect_charset(src)
      "ISO-8859-1"
    end
  end
end

interface = SmarterMeter::Interfaces::Swing.new
SmarterMeter::Daemon.new(interface).start
