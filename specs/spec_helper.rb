require 'rubygems'
Gem.clear_paths
ENV['GEM_HOME'] = File.join(File.dirname(__FILE__), '..', 'gems')

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'smartermeter'

$FIXTURES_DIR = File.expand_path(File.join(File.dirname(__FILE__), "fixtures"))
