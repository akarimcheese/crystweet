require "json"
require "http/client"
require "../tweet/top_level_tweet"

module Twitter::Response
    class Tweets < Twitter::Response::Cursor(Twitter::Response::TopLevelTweet, UInt64)
        include Iterator(Twitter::Response::TopLevelTweet)
        
        property collection : Array(Twitter::Response::TopLevelTweet)
        property max_id : UInt64
        property max_tweets : Int32
        property total_tweets_retrieved : Int32
        
        def initialize(body : String, @request, @max_tweets)
            @max_id = 0.to_u64
            @total_tweets_retrieved = 0
        
            # @max_id initialized here
            super(body, @request)
        end
        
        def stop?
            (@collection.size == 0) || (@cum_index >= @max_tweets)
        end
        
        def next_page
            @request.call(@max_id-1)
        end
        
        def process_json(body)
            tweet_parser = JSON::PullParser.new(body)
            @collection = Array(Twitter::Response::TopLevelTweet).new(tweet_parser).map { |tweet| tweet.extend_text }
            
            @max_id = @collection[-1].id if (@collection.size != 0)
        end
    end
end