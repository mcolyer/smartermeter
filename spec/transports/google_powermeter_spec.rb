$:.unshift File.join(File.dirname(__FILE__), "..")
require 'spec_helper'

describe SmarterMeter::Transports::GooglePowerMeter do
  before(:each) do
    @subject = SmarterMeter::Transports::GooglePowerMeter.new(:token => "secret",
                                                              :variable => "/path")
    data = File.read(File.join($FIXTURES_DIR, 'data.csv'))
    @results = SmarterMeter::Samples.parse_csv(data)
  end

  it "can format a request for the API" do
    fixture_file = File.join(File.dirname(__FILE__), "..", "fixtures", "expected_google_request.xml")
    expected_result = File.read(fixture_file)

    samples = @results.values.first
    @subject.request_body(samples).should == expected_result
  end
end
