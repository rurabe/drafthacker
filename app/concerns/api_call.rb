require 'net/http'

# This module builds the request URL, adds the parameters, and returns 
# the JSON response as a hash for API calls to CBS Sports Football.
module ApiCall #--------------------------------------------------------------------------------------------------------

  def json_response(options = {}) #eg { :api_call => 'league/details', :params => { :access_token => "csugvwu3298hfw9" } }
    JSON.parse(read_response(options), :symbolize_names => true)
  end

  private

    def read_response(options = {})
      Net::HTTP.get_response(build_url(options)).body
    end

    def build_url(options = {})
      api_call = options.fetch(:api_call)       # eg. 'league/details', !!-REQUIRED-!!
      params = build_params(options[:params]) if options[:params]   # eg. { :SPORT => "football" }, optional

      URI("http://api.cbssports.com/fantasy/#{api_call}?#{params}response_format=JSON")
    end

    def build_params(params = {}) # eg. { :SPORT => "football" }
      param_string = []
      params.each do |k,v|
        param_string << "#{k.to_s}=#{v}&"
      end
      param_string.join("")
    end
end