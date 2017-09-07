require "http/client"
require "oauth"

module Twitter
    struct Client
        property client
        
        def initialize(consumer_key, consumer_secret, access_token, access_secret)
            consumer = OAuth::Consumer.new("https://api.twitter.com/1.1/", consumer_key, consumer_secret)
            access_token = OAuth::AccessToken.new(access_token, access_secret)
            @client = HTTP::Client.new("api.twitter.com", tls: true)
            consumer.authenticate(@client, access_token)
        end
        
        def userSearch(query, params)
            request = 
                Twitter::Request.new(@client, :userSearch, params)
                .with_query(query)
            
            response = request.exec
            
            users = [] of Twitter::User
            
            Array(Twitter::User).new((JSON::PullParser.new(response.body)))
        end
        
        def getFollowersFor(user : (String | UInt64), params)
            request = 
                Twitter::Request.new(@client, :followers, params)
                    .for_user(user)
                    
            response = request.exec
            
            #Handle non-200
            Twitter::Cursor(UInt64).new(request, JSON::PullParser.new(response.body))
        end
        
        def getFollowingFor(user : (String | UInt64), params)
            request = 
                Twitter::Request.new(@client, :following, params)
                    .for_user(user)
                    
            response = request.exec
            
            #Handle non-200
            Twitter::Cursor(UInt64).new(request, JSON::PullParser.new(response.body))
        end
    end
end