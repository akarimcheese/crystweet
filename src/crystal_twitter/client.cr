require "http/client"
require "oauth"

module Twitter
    struct Client
        property client
        property retry_on_limit
        
        def initialize(consumer_key, consumer_secret, access_token, access_secret)
            consumer = OAuth::Consumer.new("https://api.twitter.com/1.1/", consumer_key, consumer_secret)
            access_token = OAuth::AccessToken.new(access_token, access_secret)
            @client = HTTP::Client.new("api.twitter.com", tls: true)
            consumer.authenticate(@client, access_token)
            @retry_on_limit = false
        end
        
        def persistent
            @retry_on_limit = true
            self
        end
        
        def userSearch(query, params)
            request = 
                Twitter::Request.new(@client, :userSearch, params)
                .with_query(query)
            
            request.ignore_rate_limit if @retry_on_limit
            response = request.exec
            
            users = [] of Twitter::User
            
            Array(Twitter::User).new((JSON::PullParser.new(response.body)))
        end
        
        def getFollowersFor(user : (String | UInt64), params)
            request = 
                Twitter::Request.new(@client, :followers, params)
                    .for_user(user)
                    
            request.ignore_rate_limit if @retry_on_limit
            response = request.exec
            
            #Handle non-200
            Twitter::Cursor(UInt64).new(request, JSON::PullParser.new(response.body))
        end
        
        def getFollowingFor(user : (String | UInt64), params)
            request = 
                Twitter::Request.new(@client, :following, params)
                    .for_user(user)
                    
            request.ignore_rate_limit if @retry_on_limit
            response = request.exec
            
            #Handle non-200
            Twitter::Cursor(UInt64).new(request, JSON::PullParser.new(response.body))
        end
    end
end