require "http/client"
require "oauth"

module Twitter
    struct Client
        property client
        property consumer_key, consumer_secret, access_token, access_secret
        property retry_on_limit
        
        def initialize(@consumer_key : String, @consumer_secret : String, @access_token : String, @access_secret : String)
            @client = HTTP::Client.new("api.twitter.com", tls: true)
            oauth()
            @retry_on_limit = false
        end
        
        def oauth
            consumer = OAuth::Consumer.new("https://api.twitter.com/1.1/", @consumer_key, @consumer_secret)
            oauth_access_token = OAuth::AccessToken.new(@access_token, @access_secret)
            @client = HTTP::Client.new("api.twitter.com", tls: true)
            consumer.authenticate(@client, oauth_access_token)
        end
        
        # def oauth_stream
        #     consumer = OAuth::Consumer.new("https://stream.twitter.com/1.1/", @consumer_key, @consumer_secret)
        #     oauth_access_token = OAuth::AccessToken.new(@access_token, @access_secret)
        #     @client = HTTP::Client.new("stream.twitter.com", tls: true)
        #     consumer.authenticate(@client, oauth_access_token)
        # end
        
        def persistent
            @retry_on_limit = true
            self
        end
        
        def userSearch(query, params)
            request = 
                Twitter::Request.new(self, :userSearch, params)
                .with_query(query)
            
            request.ignore_rate_limit if @retry_on_limit
            response = request.exec
            
            users = [] of Twitter::User
            
            Array(Twitter::User).new((JSON::PullParser.new(response.body)))
        end
        
        def getFollowersFor(user : (String | UInt64), params)
            request = 
                Twitter::Request.new(self, :followers, params)
                    .for_user(user)
                    
            request.ignore_rate_limit if @retry_on_limit
            response = request.exec
            
            #Handle non-200
            Twitter::Cursor(UInt64).new(request, JSON::PullParser.new(response.body))
        end
        
        def getFollowingFor(user : (String | UInt64), params)
            request = 
                Twitter::Request.new(self, :following, params)
                    .for_user(user)
                    
            request.ignore_rate_limit if @retry_on_limit
            response = request.exec
            
            #Handle non-200
            Twitter::Cursor(UInt64).new(request, JSON::PullParser.new(response.body))
        end
        
        # def stream
        #     @client = HTTP::Client.new("stream.twitter.com", tls: true)
        #     oauth_stream()
            
        #     params = "track=nfl"
            
        #     puts "we out here"
            
        #     @client.connect_timeout = 60*60*24
        #     @client.read_timeout = 60*60*24
            
        #     @client.post("https://stream.twitter.com/1.1/statuses/filter.json?#{params}") do |response|
        #       puts "we in here"
        #       puts response.inspect
        #       puts response.status_code  # => 200
        #       while !response.body_io.closed?
        #         puts response.body_io.gets("\r\n")
        #       end
        #     end
        # end
    end
end