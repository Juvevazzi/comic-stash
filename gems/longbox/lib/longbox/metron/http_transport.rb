module Longbox
  module Metron
    # The real connection: one GET request with Net::HTTP (part of Ruby).
    # It is the only code that touches the network, and it's deliberately
    # small, because the tests swap it for a fake.
    class HttpTransport
      def call(uri, headers)
        request = Net::HTTP::Get.new(uri)
        headers.each { |name, value| request[name] = value }

        response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https",
                                                       open_timeout: 5, read_timeout: 15) do |http|
          http.request(request)
        end

        Response.new(status: response.code.to_i,
                     headers: response.each_header.to_h,
                     body: response.body.to_s)
      end
    end
  end
end
