require 'rubygems'
require 'bundler/setup'
Bundler.require(:default, :development)

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'smartermeter'

$FIXTURES_DIR = File.expand_path(File.join(File.dirname(__FILE__), "fixtures"))
