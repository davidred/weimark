require 'nokogiri'
require 'httparty'
require 'active_support/core_ext/hash/conversions'

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
      request(
        http_method: :post,
        endpoint: url,
        body: { request: xml_get_request(application_id) }
      )
    end

    private

    def request(http_method:, endpoint:, body: {})
      response = Weimark::Response.new(HTTParty.public_send(http_method, endpoint, body: body))
    end

    def xml_get_request(application_id)
      Nokogiri::XML::Builder.new do |xml|
        xml.root {
          xml.action "GetApplication"
          xml.email email
          xml.password password
          xml.request {
            xml.applicationid application_id
          }
        }
      end.to_xml.gsub("root", "xml")
    end
  end

  class Response
    attr_reader :parsed_response, :status, :message, :application, :report

    # {"application"=>{"id"=>"3x7gda8bz6drq5d4d79faee07x80y5i0", "timestamp"=>"08/21/2018 14:43:24", "link"=>"https://secure.weimark.com/applications/view/380854", "status"=>"COMPLETED"}, "report"=>{"decision"=>"Excellent", "ficoscores"=>{"applicants"=>{"applicant"=>{"name"=>"John Doe", "score"=>"850"}}}, "fullreport"=>""}}}
    def initialize(response)
      @parsed_response = Hash.from_xml(response)['xml']
      @status = parsed_response['status']

      if successful?
        result = @parsed_response['result']
        @application = Weimark::Application.new(result['application'])
        @report = Weimark::Report.new(result['report'])
      else
        @message = parsed_response['message']
      end
    end

    def successful?
      status != 'ERROR'
    end

    def errors
      successful? ? [] : [parsed_response['message']]
    end
  end

  class Application
    attr_reader :id, :timestamp, :link, :status

    def initialize(application_attributes = {})
      @id = application_attributes['id']
      @timestamp = application_attributes['timestamp']
      @link = application_attributes['link']
      @status = application_attributes['status']
    end
  end

  class Report
    attr_reader :decision, :score, :name

    def initialize(report_attributes = {})
      @decision = report_attributes['decision']
      @score = report_attributes['ficoscores'].try(:[], 'applicants').try(:[], 'applicant').try(:[], 'score')
      @name = report_attributes['ficoscores'].try(:[], 'applicants').try(:[], 'applicant').try(:[], 'name')
    end
  end
end
