$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'rubygems'
require 'fetch'

$FIXTURES_DIR = File.expand_path(File.join(File.dirname(__FILE__), "fixtures"))
