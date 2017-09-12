require "./crystal_twitter/*"
require "./crystal_twitter/rest/*"
require "./crystal_twitter/stream/*"
require "./crystal_twitter/models/request/*"

module Twitter
    client = Twitter::Rest::Client.new(
        ENV["TWITTER_CONSUMER_KEY"], 
        ENV["TWITTER_CONSUMER_SECRET"], 
        ENV["TWITTER_ACCESS_TOKEN"],
        ENV["TWITTER_ACCESS_SECRET"]
    ).persistent
    
    user_ids = Twitter::Request::User.new(
        client,
        "jordwalke"
    )#.following_ids(stringify_ids: true)
    .following_ids()
    .to_a
    
    puts user_ids.size
    
    sleep(5)
    
    users = Twitter::Request::UserLookup.new(client, user_ids).lookup_users
    puts users.size
    
    # Twitter::Stream::Client.new(
    #     ENV["TWITTER_CONSUMER_KEY"], 
    #     ENV["TWITTER_CONSUMER_SECRET"], 
    #     ENV["TWITTER_ACCESS_TOKEN"],
    #     ENV["TWITTER_ACCESS_SECRET"]
    # ).stream
end
