# Stands in for HttpTransport in the tests: it never touches the network.
# Queue up the responses Metron would send, then check what was asked for.
class FakeTransport
  attr_reader :requests

  def initialize(*responses)
    @responses = responses
    @requests = []
  end

  def call(uri, headers)
    @requests << { uri: uri.to_s, headers: headers }
    @responses.shift || raise("FakeTransport has no response left for #{uri}")
  end

  # A JSON response, as Metron would send it.
  def self.json(body, status: 200, headers: {})
    Longbox::Metron::Response.new(status: status, headers: headers, body: JSON.generate(body))
  end
end
