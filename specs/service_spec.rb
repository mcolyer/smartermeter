$:.unshift File.join(File.dirname(__FILE__))
require 'spec_helper'

describe SmartMeterService do
  before(:each) do
    @subject = SmartMeterService.new
    @date = Date.new(2009, 9, 30)
    @data = File.read(File.join($FIXTURES_DIR, 'data.csv'))
  end

  it "should be able to create a LocalRepository of an existing repository" do
    results = @subject.send(:parse_csv, @data)

    results.length.should > 0
    results.keys.should include(@date)
    results[@date].length.should == 24
    results[@date].each{|s| s.should be_kind_of(Sample)}
  end

  it "should retrieve results correctly from the cache" do
    @subject.send(:parse_csv, @data)

    results = @subject.fetch_day(@date)
    results.length.should == 24
    results.each{|s| s.should be_kind_of(Sample)}
  end
end
