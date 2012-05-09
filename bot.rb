#!/usr/bin/env ruby
require 'pp'
require 'pit'
require 'user_stream'
require 'twitter'

name = -> s { s.split(':').first }
open('twitter_leak') {|f| $screen_names = f.readlines.map(&name) }

config = Pit.get('twitter', require: {
  consumer_key: "your consumer key",
  consumer_secret: "your consumer secret",
  oauth_token: "your oauth token",
  oauth_token_secret: "your oauth token secret"
})

UserStream.configure do |c|
  c.consumer_key = config[:consumer_key]
  c.consumer_secret = config[:consumer_secret]
  c.oauth_token = config[:oauth_token]
  c.oauth_token_secret = config[:oauth_token_secret]
end

Twitter.configure do |c|
  c.consumer_key = config[:consumer_key]
  c.consumer_secret = config[:consumer_secret]
  c.oauth_token = config[:oauth_token]
  c.oauth_token_secret = config[:oauth_token_secret]
end

client = UserStream.client
client.user do |status|
  begin
    pp status
    screen_name = status['user']['screen_name'] if status['user']
    if status['in_reply_to_screen_name']
      if $screen_names.index(screen_name)
        message = "your twitter password is leaked!"
      else
        message = "your twitter password is *NOT* leaked!"
      end
      Twitter.update "@#{screen_name} #{message}", in_reply_to_status_id: status['id']
    end
  rescue
  end
end
