require 'nokogiri'
require 'httparty'
require 'active_support/core_ext/hash/conversions'

module Weimark
  class Client
    WEIMARK_URL = 'https://secure.weimark.com/api/post'.freeze

    attr_reader :url, :email, :password, :agents_email

    def initialize(options = {})
      @url = options[:url] || WEIMARK_URL
      @email = options[:email] || ENV['WEIMARK_EMAIL']
      @password = options[:password] || ENV['WEIMARK_PASSWORD']
      @agents_email = options[:agents_email] || ENV['AGENTS_EMAIL']
    end

    def get(application_id)
      request(
        http_method: :post,
        endpoint: url,
        body: {
          request: xml_request(
            action: "GetApplication",
            agents_email: agents_email,
            body: {
              applicationid: application_id
            }
          )
        }
      )
    end

    # Sample application_attributes:
    # {fname: 'JONATHAN', lname: 'CONSUMER', dob: '01/05/1987', gender: 'male', ssn: '485774859', streetnumber: '236', streetname: 'BIRCH', streettype: 'S', city: 'BURBANK', country: 'USA', suite: '1TEST', zip: '91502'}
    def post(application_attributes = {})
      request(
        http_method: :post,
        endpoint: url,
        body: {
          request: xml_request(
            action: "NewApplication",
            agents_email: agents_email,
            body: {
              applicant: application_attributes
            }
          )
        }
      )
    end

    private

    def request(http_method:, endpoint:, body: {})
      response = Weimark::Response.new(HTTParty.public_send(http_method, endpoint, body: body))
    end

    def xml_request(action:, agents_email:, body: {})
      Nokogiri::XML::Builder.new do |xml|
        xml.root {
          xml.action action
          xml.email email
          xml.password password
          xml.agents_email agents_email
          xml.request {
            body.each do |k, v|
              if v.is_a?(Hash)
                xml.send(k) {
                  v.each { |k, v| xml.send(k, v)  }
                }
              else
                xml.send(k, v)
              end
            end
          }
        }
      end.to_xml.gsub("root", "xml")
    end
  end

  class Response
    attr_reader :response, :parsed_response, :status, :message, :application, :report

    # {"application"=>{"id"=>"3x7gda8bz6drq5d4d79faee07x80y5i0", "timestamp"=>"08/21/2018 14:43:24", "link"=>"https://secure.weimark.com/applications/view/380854", "status"=>"COMPLETED"}, "report"=>{"decision"=>"Excellent", "ficoscores"=>{"applicants"=>{"applicant"=>{"name"=>"John Doe", "score"=>"850"}}}, "fullreport"=>""}}}
    def initialize(response)
      @response = response
      @parsed_response = Hash.from_xml(response)['xml']
      @status = parsed_response['status']

      if successful?
        result = @parsed_response['result']
        application = result['application']
        application.merge!('id' => result['applicationid']) if result['applicationid']
        @application = Weimark::Application.new(application)
        @report = Weimark::Report.new(result['report']) if result['report']
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
    attr_reader :decision, :score, :name, :fullreport

    def initialize(report_attributes = {})
      @decision = report_attributes.try(:[], 'decision')
      @fullreport = report_attributes.try(:[], 'fullreport')
      @score = report_attributes.try(:[], 'ficoscores').try(:[], 'applicants').try(:[], 'applicant').try(:[], 'score')
      @name = report_attributes.try(:[], 'ficoscores').try(:[], 'applicants').try(:[], 'applicant').try(:[], 'name')
    end
  end
end
