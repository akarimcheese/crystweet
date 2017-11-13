require "json"
require "http"
require "../response/cursors/*"

module Twitter::Request
    class User
        @user_id : UInt64?
        @screen_name : String?
        
        def initialize(@client : Twitter::Rest::Client, @user_id : UInt64)
        end
        
        def initialize(@client : Twitter::Rest::Client, identifier : String, using_user_id? : Bool? = false)
            if using_user_id?
                @user_id = identifier.to_u64
            else
                @screen_name = identifier
            end
        end
        
        def show(include_entities : Bool? = nil)
            endpoint = "users/show.json?"
            
            params = {} of String => (String | Nil)
            
            params["user_id"] = @user_id.to_s if @user_id
            params["screen_name"] = @screen_name if @screen_name
            params["include_entities"] = include_entities.to_s if include_entities
            params.compact! # Safekeeping
            
            response = get(endpoint, params)
            
            user_parser = JSON::PullParser.new(response.body)
            return Twitter::Response::User.new(user_parser)
        end
        
        # List Version
        def followers_list(cursor : UInt64? = nil, count : Int32? = nil, skip_status : Bool? = nil, include_user_identities : Bool? = nil)
            # TODO https://dev.twitter.com/rest/reference/get/followers/list
        end
        
        # IDs version
        def followers_ids(cursor : UInt64? = nil, count : Int32? = nil, stringify_ids : Bool? = nil)
            endpoint = "followers/ids.json?"
        
            params = {} of String => (String | Nil)
            
            params["user_id"] = @user_id.to_s if @user_id
            params["screen_name"] = @screen_name if @screen_name
            params["cursor"] = cursor.to_s if cursor
            params["count"] = count.to_s if count
            params["stringify_ids"] = stringify_ids.to_s if stringify_ids
            params.compact! # Safekeeping
        
            response = get(endpoint, params)
            
            request = 
                ->(next_cursor : UInt64) { 
                    params["cursor"] = next_cursor.to_s
                    get(endpoint, params)
                }
            
            if stringify_ids
                Twitter::Response::UserIDCursor(String).new(
                    response.body, 
                    request
                )
            else
                Twitter::Response::UserIDCursor(UInt64).new(
                    response.body, 
                    request
                )
            end
        end
        
        # List Version
        def following_list(cursor : UInt64? = nil, count : Int32? = nil, skip_status : Bool? = nil, include_user_identities : Bool? = nil)
            # TODO https://dev.twitter.com/rest/reference/get/friends/list
        end
        
        # IDs version
        def following_ids(cursor : UInt64? = nil, count : Int32? = nil, stringify_ids : Bool? = nil)
            endpoint = "friends/ids.json?"
        
            params = {} of String => (String | Nil)
            
            params["user_id"] = @user_id.to_s if @user_id
            params["screen_name"] = @screen_name if @screen_name
            params["cursor"] = cursor.to_s if cursor
            params["count"] = count.to_s if count
            params["stringify_ids"] = stringify_ids.to_s if stringify_ids
            params.compact! # Safekeeping
        
            response = get(endpoint, params)
            
            request = 
                ->(next_cursor : UInt64) { 
                    params["cursor"] = next_cursor.to_s
                    get(endpoint, params)
                }
            
            if stringify_ids
                Twitter::Response::UserIDCursor(String).new(
                    response.body, 
                    request
                )
            else
                Twitter::Response::UserIDCursor(UInt64).new(
                    response.body, 
                    request
                )
            end
        end
        
        # TODO: Make an iterator and simulate pagination or something
        def tweets(count : Int32? = nil, since_id : UInt64? = nil, max_id : UInt64? = nil, exclude_replies : Bool? = nil, include_retweets : Bool? = nil, trim_user : Bool? = nil)
            endpoint = "statuses/user_timeline.json?"
        
            params = {} of String => (String | Nil)
            
            params["user_id"] = @user_id.to_s if @user_id
            params["screen_name"] = @screen_name if @screen_name
            params["count"] = [200, count].min.to_s if count
            params["since_id"] = since_id.to_s if since_id
            params["max_id"] = max_id.to_s if max_id
            params["exclude_replies"] = exclude_replies.to_s if (exclude_replies != nil)
            params["include_rts"] = include_retweets.to_s if (include_retweets != nil)
            params["trim_user"] = trim_user.to_s if (trim_user != nil)
            params["tweet_mode"] = "extended"
            params.compact! # Safekeeping
            
            
                
            response = get(endpoint, params)
            
            if (count <= 200)
                tweet_parser = JSON::PullParser.new(response.body)
                tweets = Array(Twitter::Response::TopLevelTweet).new(tweet_parser).map { |tweet| tweet.extend_text }
        
                return tweets
            end
            
            request = 
                ->(max_id : UInt64) { 
                    params["max_id"] = max_id.to_s
                    get(endpoint, params)
                }
            
            Twitter::Response::Tweets.new(response.body, request, count)
        end
        
        # TODO: Find a way to refactor this to share code with other requests made
        def get(endpoint, params)
            encoded_params = HTTP::Params.encode(params)
            response = @client.get("https://api.twitter.com/1.1/#{endpoint}#{encoded_params}")
            
            return response
        end
        
        # Not directly API Calls
        def is_following?(target_identifier : (UInt64|String))
            relationship = @client.relationship(
                @user_id || @screen_name || UInt64.new(0), 
                target_identifier
            ).show()
            
            return relationship.source.following
        end
        
        def is_followed_by?(target_identifier : (UInt64|String))
            relationship = @client.relationship(
                @user_id || @screen_name || UInt64.new(0), 
                target_identifier
            ).show()
            
            return relationship.source.followed_by
        end
    end
end