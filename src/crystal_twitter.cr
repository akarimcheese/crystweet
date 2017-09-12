require "./crystal_twitter/*"
require "./crystal_twitter/rest/*"
require "./crystal_twitter/stream/*"
require "./crystal_twitter/models/request/*"

module Twitter
    # client = Twitter::Rest::Client.new(
    #     ENV["TWITTER_CONSUMER_KEY"], 
    #     ENV["TWITTER_CONSUMER_SECRET"], 
    #     ENV["TWITTER_ACCESS_TOKEN"],
    #     ENV["TWITTER_ACCESS_SECRET"]
    # ).persistent
    
    # puts Twitter::Request::User.new(
    #     "jordwalke",
    #     client
    # ).following_ids(stringify_ids: true).to_a.size
    
    Twitter::Stream::Client.new(
        ENV["TWITTER_CONSUMER_KEY"], 
        ENV["TWITTER_CONSUMER_SECRET"], 
        ENV["TWITTER_ACCESS_TOKEN"],
        ENV["TWITTER_ACCESS_SECRET"]
    ).stream
end
