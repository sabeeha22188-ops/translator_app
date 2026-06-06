class SampleFeature
  def initialize(payload = nil)
    @payload = payload
  end

  def run
    "SampleFeature ran with #{@payload.inspect}"
  end
end
