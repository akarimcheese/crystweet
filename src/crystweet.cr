require "./crystweet/*"
require "./crystweet/rest/*"
require "./crystweet/stream/*"
require "./crystweet/models/request/*"
require "./crystweet/models/response/*"

module Twitter
    # client = Twitter::Rest::Client.new(
    #     ENV["TWITTER_CONSUMER_KEY"], 
    #     ENV["TWITTER_CONSUMER_SECRET"], 
    #     ENV["TWITTER_ACCESS_TOKEN"],
    #     ENV["TWITTER_ACCESS_SECRET"]
    # ).persistent
    
    # user_ids = Twitter::Request::User.new(
    #     client,
    #     "jordwalke"
    # )#.following_ids(stringify_ids: true)
    # .following_ids()
    # .to_a
    
    # puts user_ids.size
    
    # sleep(5)
    
    # users = Twitter::Request::UserLookup.new(client, user_ids).lookup_users
    # puts users.size
    
    # puts client.search("john cena").users[0].inspect
    
    Twitter::Stream::Client.new(
        ENV["TWITTER_CONSUMER_KEY"], 
        ENV["TWITTER_CONSUMER_SECRET"], 
        ENV["TWITTER_ACCESS_TOKEN"],
        ENV["TWITTER_ACCESS_SECRET"]
    )
    .stream(track: ["WWE", "John Cena", "Roman Reigns"]) do |tweet|
        puts tweet
    end
end
