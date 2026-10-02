require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
require 'rspec'
require 'vcr'

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'smartermeter'

RSpec.configure do |config|
  config.expect_with(:rspec) { |expectations| expectations.syntax = [:should, :expect] }
end

$FIXTURES_DIR = File.expand_path(File.join(File.dirname(__FILE__), "fixtures"))

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
end
