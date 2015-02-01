require 'net/http'
require 'json'

module MeetupThingy
  class MeetupAPI
    attr_reader :api_key

    def initialize(api_key = nil)
      @base_uri = 'api.meetup.com'
      @groups_endpoint = '/2/groups'
      @events_endpoint = '/2/events'
      @api_key = api_key || ENV['MEETUP_API_KEY'] || raise('no MEETUP_API_KEY provided')
    end

    def get_meetup_id group_url_name
      uri = URI::HTTP.build(:host => @base_uri, :path => @groups_endpoint, :query => 'key=' + @api_key + '&group_urlname=' + group_url_name)
      extract_meetup_id get_meetup_response(uri)
    end

    def get_upcoming_events group_ids
      uri = URI::HTTP.build(:host => @base_uri, :path => @events_endpoint, :query => 'sign=true&photo-host=public&status=upcoming&key=' + @api_key + '&group_id=' + group_ids.join(','))
      response = get_meetup_response uri
      get_results response
    end

    private

    def get_meetup_response uri
      response = Net::HTTP.get_response uri

      if response.code != "200"
        msg = "Call to #{uri} failed: HTTP #{response.code} - #{response.message}"

        if response.class.body_permitted?
          msg << '. ' + response.body
        end

        raise(msg)
      end

      JSON.parse response.body
    end

    def extract_meetup_id response
      get_results(response)[0]['id']
    end

    def get_results response
      response['results']
    end

  end
end