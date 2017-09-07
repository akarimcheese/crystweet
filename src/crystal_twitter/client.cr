require "http/client"
require "oauth"

module Twitter
    struct Client
        property client, endpoint_mapping
        
        def initialize(consumer_key, consumer_secret, access_token, access_secret)
            consumer = OAuth::Consumer.new("https://api.twitter.com/1.1/", consumer_key, consumer_secret)
            access_token = OAuth::AccessToken.new(access_token, access_secret)
            @client = HTTP::Client.new("api.twitter.com", tls: true)
            consumer.authenticate(@client, access_token)
            
            @endpoint_mapping = Twitter::EndpointMapping.new
        end
        
        def userSearch(query, params)
            endpoint = @endpoint_mapping[:userSearch]
            request = 
                Twitter::Request.new(@client, endpoint, params)
                .with_query(query)
            
            response = request.exec
            
            users = [] of Twitter::User
            
            Array(Twitter::User).new((JSON::PullParser.new(response.body)))
        end
        
        def getFollowersFor(user : (String | UInt64), params)
            endpoint = @endpoint_mapping[:followers]
            request = 
                Twitter::Request.new(@client, endpoint, params)
                    .for_user(user)
                    
            response = request.exec
            
            #Handle non-200
            
            Twitter::Cursor(UInt64).new(request, JSON::PullParser.new(response.body))
        end
    end
end