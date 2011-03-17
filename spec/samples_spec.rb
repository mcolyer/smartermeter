require 'spec_helper'

describe SmarterMeter::Samples do
  before(:all) do
    @data = File.read(File.join($FIXTURES_DIR, 'data.csv'))
    @date_present = Date.new(2009, 9, 27)
  end

  subject { SmarterMeter::Samples.parse_csv(@data) }

  it "can calculate the total number of kilowatt hours used" do
    subject.total_kwh.should be_within(0.1).of(43.72)
  end

  it "can calculate the total number of kilowatt hours used on a specific day" do
    subject.total_kwh_on(Date.new(2009, 9, 27)).should be_within(0.1).of(16.65)
  end

  it "can calculate the total number of kilowatt hours used on a day not given" do
    subject.total_kwh_on(Date.new(2010, 9, 27)).should == 0
  end

  it "can access samples for a given day" do
    subject.length.should == 7
    subject.keys.should include(@date_present)
    subject[@date_present].length.should == 24
    subject[@date_present].each{|s| s.should be_kind_of(SmarterMeter::Sample)}
  end

  it "can handle an incomplete sample" do
    subject[@date_present][0].kwh.should == nil
    subject[@date_present][0].time.should == Time.local(2009, 9, 27, 0)
  end

  it "can handle a complete sample" do
    subject[@date_present][1].kwh.should == 0.205
    subject[@date_present][1].time.should == Time.local(2009, 9, 27, 1)
  end
end
