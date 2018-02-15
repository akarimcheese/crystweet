require "../client"
require "../models/response/tweet/top_level_tweet"

# TODO: Handle all message types
# https://dev.twitter.com/streaming/overview/messages-types
# Blank Lines [x]
# Status deletion notices [ ]
# Limit notices [ ] ex. {"limit":{"track":6,"timestamp_ms":"1506760710929"}}
# Location deletion notices [ ]
# Withheld content notices [ ]
# Disconnect messages [ ]
# Stall warnings [ ]
# User update [ ]
# TODO: Handle rare cases
# https://dev.twitter.com/streaming/overview/processing
# Handle missing fields [ ]
# Handle missing counts [ ]
#  - Backfill as needed? [ ]
# Handle duplicate messages [ ]
# CONSIDER: Thread pool or queue for processing tweets
module Twitter::Stream
    class Client < Twitter::Client
        
        @include_retweets : Bool?
        @include_quotes : Bool?
        @include_replies : Bool?
        
        def base_url
            "stream.twitter.com"
        end
        
        def api_version
            "1.1"
        end
        
        # TODO: Use enum/symbol/constant
        def exclude(*types)
            types.each do |type|
                case type
                when :retweet
                    @include_retweets = false
                when :quote
                    @include_quotes = false
                when :reply
                    @include_replies = false
                end
            end
            self
        end
        
        # TODO: Use enum/symbol/constant
        def include(*types)
            types.each do |type|
                case type
                when :retweet
                    @include_retweets = true
                when :quote
                    @include_quotes = true
                when :reply
                    @include_replies = true
                end
            end
            self
        end
        
        # Info regarding params: https://dev.twitter.com/streaming/overview/request-parameters
        # TODO: add and handle locations, delimited, & stall params
        # TODO: add options to exclude: retweets, quotes, replies
        # TODO: add options to only include: retweets, quotes, replies
        def stream(follow : Array(UInt64)? = nil, track : Array(String)? = nil)
            oauth()
            
            params_check(follow, track)
            
            params = {} of String => (String | Nil)
            compact_params : Hash(String, String)
            
            params["follow"] = follow.join(",") if follow
            params["track"] = track.join(",") if track
            compact_params = params.compact # Safekeeping
            
            # TODO: verify that 2 lines below are necessary
            @client.connect_timeout = 60*60*24
            @client.read_timeout = 60*60*24
            
            post_stream(compact_params) do |line|
                # puts JSON.parse(line).as_h.keys.inspect
                # puts JSON.parse(line)["entities"]
                # puts "Retweeted tweet? #{JSON.parse(line)["retweeted_status"]? != nil}"
                # if JSON.parse(line)["retweeted_status"]?
                #     puts JSON.parse(line)["retweeted_status"].as_h.keys.inspect
                #     puts JSON.parse(line)["retweeted_status"]["entities"]
                # end
                # puts "Quoted tweet? #{JSON.parse(line)["quoted_status"]? != nil}"
                # if JSON.parse(line)["quoted_status"]?
                #     puts JSON.parse(line)["quoted_status"].as_h.keys.inspect
                #     puts JSON.parse(line)["quoted_status"]["entities"]
                # end
                
                begin
                    
                    # start = Time.now()
                    tweet = Twitter::Response::TopLevelTweet.extended_new_while_streaming(JSON::PullParser.new(line)) 
                    # finish = Time.now()
                    # puts "Time to parse: #{(finish - start).total_milliseconds}"

                    yield tweet if include_tweet(tweet)
                # FIXME: Replace/modify error handling to handle all
                # message types. 
                # See TODO on top of file for all message types.
                rescue exception
                    puts exception.inspect
                    puts "Error!!! Posting raw text"
                    puts line
                    return
                end
            end
        end
        
        def include_tweet(tweet : Twitter::Response::Tweet) : Bool
            (@include_retweets || !tweet.is_retweet?) &&
            (@include_quotes   || !tweet.is_quote?) &&
            (@include_replies  || !tweet.is_reply?)
        end
        
        def params_check(follow, track)
            if follow && follow.size > 5000
                raise "Cannot follow more than 5000 user ids"
            elsif track && track.size > 400
                raise "Cannot track more than 400 keywords"
            end
        end
        
        # TODO: stream_as_strings
        
        def post_stream(params)
            @client.post("https://stream.twitter.com/1.1/statuses/filter.json?", form: params) do |response|
              while !response.body_io.closed?
                # FIXME: break these two lines up into better, readable steps
                string = response.body_io.gets("\r\n")
                yield string if string && !string.blank?
              end
            end
        end
    end
end