require 'nokogiri'

module Weimark
  class Client
    WEIMARK_URL = 'https://secure.weimark.com/api/post'.freeze

    attr_reader :url, :email, :password

    def initialize(options = {})
      @url = options[:url] || WEIMARK_URL
      @email = options[:email] || ENV['WEIMARK_EMAIL']
      @password = options[:password] || ENV['WEIMARK_PASSWORD']
    end

    def get(application_id)
      HTTParty.post(url, body: { request: xml_get_request(application_id) })
    end

    def xml_get_request(application_id)
      Nokogiri::XML::Builder.new do |xml|
        xml.action "GetApplication"
        xml.email email
        xml.password password
        xml.request {
          xml.applicationid application_id
        }
      end.to_xml
    end
  end
end
