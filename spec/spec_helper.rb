require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
require 'rspec'
require 'vcr'

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'smartermeter'

$FIXTURES_DIR = File.expand_path(File.join(File.dirname(__FILE__), "fixtures"))

VCR.config do |c|
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.stub_with :webmock
end
