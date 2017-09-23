require "../client"
require "../request"
require "../models/response/*"

module Twitter::Rest
    class Client < Twitter::Client
        property retry_on_limit
        
        def base_url
            "api.twitter.com"
        end
        
        def api_version
            "1.1"
        end
        
        def persistent
            @retry_on_limit = true
            self
        end
        
        # def userSearch(query, params)
        #     request = 
        #         Twitter::Request.new(self, :userSearch, params)
        #         .with_query(query)
            
        #     request.ignore_rate_limit if @retry_on_limit
        #     response = request.exec
            
        #     users = [] of Twitter::Response::User
            
        #     Array(Twitter::Response::User).new((JSON::PullParser.new(response.body)))
        # end
        
        # def getFollowersFor(user : (String | UInt64), params)
        #     request = 
        #         Twitter::Request.new(self, :followers, params)
        #             .for_user(user)
                    
        #     request.ignore_rate_limit if @retry_on_limit
        #     response = request.exec
            
        #     #Handle non-200
        #     Twitter::Cursor(UInt64).new(request, JSON::PullParser.new(response.body))
        # end
        
        # def getFollowingFor(user : (String | UInt64), params)
        #     request = 
        #         Twitter::Request.new(self, :following, params)
        #             .for_user(user)
                    
        #     request.ignore_rate_limit if @retry_on_limit
        #     response = request.exec
            
        #     #Handle non-200
        #     Twitter::Cursor(UInt64).new(request, JSON::PullParser.new(response.body))
        # end
        
        def get(url)
            oauth()
            response = @client.get(url)
            
            if response.status_code == 200
                return response
            elsif response.status_code == 429 && @retry_on_limit
                puts "Rate limit reached... sleeping and retrying after 15 minutes..."
                sleep(15*60 + 5)
                return get(url)
            else
                # Replace with typed exception
                raise JSON.parse(response.body)["errors"].map{|err| err["message"].as_s }.join(",")
            end
        end
        
        def post(url, params)
            oauth()
            response = @client.post_form(url, params)
            
            if response.status_code == 200
                return response
            elsif response.status_code == 429 && @retry_on_limit
                puts "Rate limit reached... sleeping and retrying after 15 minutes..."
                sleep(15*60 + 5)
                return get(url)
            else
                # Replace with typed exception
                raise JSON.parse(response.body)["errors"].map{|err| err["message"].as_s }.join(",")
            end
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
        
        def user(identifier)
            Twitter::Request::User.new(self, identifier)
        end
        
        def search(query)
            Twitter::Request::Search.new(self, query)
        end
        
        def user_lookup(identifiers)
            Twitter::Request::UserLookup.new(self, identifiers)
        end
    end
end