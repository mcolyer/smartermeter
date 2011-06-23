require 'spec_helper'

describe SmarterMeter::Daemon do
  subject { SmarterMeter::Daemon.new(nil) }

  it "can handle a password of length 1" do
    subject.instance_variable_set(:@config, {})
    subject.send(:password=, "1")
    subject.send(:password).should == "1"
  end

  it "can handle a password of length 9" do
    subject.instance_variable_set(:@config, {})
    subject.send(:password=, "000000001")
    subject.send(:password).should == "000000001"
  end
end
