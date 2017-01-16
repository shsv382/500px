#!/usr/bin/ruby
require 'rubygems'
require 'oauth'
require 'multi_json'

class Session

CONSUMER_KEY = 'GpvBgcMoKkUJCt15stvd8jaxyO75IFIUjX2o1Fqp'
CONSUMER_SECRET = 'XKYwiMfb1hd2popHP4BSdDpoNs5w824B6vxZZGOE'

def initialize(username, password)
  @username = username
  @password = password
end

BASE_URL = 'https://api.500px.com'

def get_access_token
  p "get_access_token: Initializing Consumer" 
  consumer = OAuth::Consumer.new(CONSUMER_KEY, CONSUMER_SECRET, {
  :site               => BASE_URL,
  :request_token_path => "/v1/oauth/request_token",
  :access_token_path  => "/v1/oauth/access_token",
  :authorize_path     => "/v1/oauth/authorize"})

  request_token = consumer.get_request_token()
  p "Request URL: #{request_token.authorize_url}"
  access_token = consumer.get_access_token(request_token, {}, { :x_auth_mode => 'client_auth', :x_auth_username => @username, :x_auth_password => @password })
  access_token
end

def main
  access_token = get_access_token
  p "token: #{access_token.token}" 
  p "secret: #{access_token.secret}"
  puts
  puts "Logged in as #{@username}"
  puts

  photos = []
  photos = photos + shots(access_token)
  photos = photos.uniq
  photos.each do |photo|
    puts
    puts "#{photo.to_s}: L ike or S kip"
    case gets.chomp.downcase
    when "l" || "f" || "v"
      voting(access_token, photo)
      comment(access_token, photo)
    when "s" || "q" || "n"
      next
    end
  end
end

def shots(access_token)
  obj = MultiJson.decode(access_token.get('/v1/photos?feature=fresh_today&sort=created_at.json').body)
  photos = []
  obj["photos"].each do |photo|
    photos << photo["id"]
  end
  photos
end

def voting(access_token, photo)
  uri_vote = "/v1/photos/#{photo}/vote?vote=1"
  puts "voting for #{photo}"
  access_token.post(uri_vote)
end

def comment(access_token, photo)
  puts "Enter your comment on #{photo}"
  comment = gets.chomp
  comment = comment.gsub(" ", "%20")
  uri = "/v1/photos/#{photo}/comments?body=#{comment}"
  access_token.post(uri)
  puts "commented on #{photo}"
end

end

puts "Enter username"
username = gets.chomp

puts "Password"
password = gets.chomp

connect = Session.new(username, password)
connect.main
#puts shots.inspect