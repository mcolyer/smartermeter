module SmarterMeter
  class Sample
    attr_accessor :time, :kwh

    def initialize(time, kwh)
      @time = time
      @kwh = kwh
    end

    def inspect
      "<Sample #{@time} #{@kwh}>"
    end
  end
end
