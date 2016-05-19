#! /usr/bin/env ruby

require 'net/http'
require 'json'
require 'pry'

class Query
  def initialize(api_key)
    raise "Api key required" unless api_key

    @api_key = api_key
  end

  def notice_details(project_id, fault_id)
    uri = "https://app.honeybadger.io/v1/projects/#{project_id}"\
        "/faults/#{fault_id}/notices?auth_token=#{@api_key}"

    resp = Net::HTTP.get(URI(uri))

    hash = JSON.parse resp

    current_page = hash['current_page'].to_i
    num_pages = hash['num_pages'].to_i

    puts current_page
    puts num_pages

    emails = []

    (current_page..num_pages).each do |page|
      puts "retrieving page #{page}"

      resp = Net::HTTP.get(URI(uri + "&page=#{page}"))
      hash = JSON.parse resp

      hash['results'].each do |result|
        date = DateTime.parse(result['created_at'])

        if date > DateTime.new(2016,05,12)
          emails << result['request']['context']['user_email']
        end
      end
    end

    emails.uniq.each do |email| puts email end
  end
end

query = Query.new ARGV[0]
query.notice_details ARGV[1], ARGV[2]
