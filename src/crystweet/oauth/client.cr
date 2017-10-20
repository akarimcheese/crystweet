require "../client"
require "../request"
require "../models/response/*"
require "../models/response/tweet/*"
require "../rest/*"
require "../stream/*"

module Twitter::Auth
    class Client < Twitter::Client
        def initialize(consumer_key, consumer_secret, access_token, access_secret)
            super(consumer_key, consumer_secret, access_token, access_secret)
        end
        
        def base_url
            "api.twitter.com"
        end
        
        def api_version
            "1.1"
        end
        
        # TODO: Move to interface level
        def oauth_request_token(callback_url)
            params = {"oauth_callback" => callback_url}
            response = @client.post_form("https://api.twitter.com/oauth/request_token", params).body
            authorization_endpoint = "https://api.twitter.com/oauth/authorize?oauth_token="
            
            if response =~ /^oauth_token=([^&]+)&oauth_token_secret=([^&]+)&/
                puts response
                return {
                    "oauth_token" => $1, 
                    "oauth_token_secret" => $2,
                    "oauth_authorization_link" => "#{authorization_endpoint}#{$1}"
                }
            end
            raise "No oauth token returned"
        end
        
        def oauth_access_token(oauth_token, oauth_verifier)
            oauth_client = HTTP::Client.new(base_url, tls: true)
            OAuth.authenticate(oauth_client, oauth_token, nil, @consumer_key, @consumer_secret)
            
            params = {"oauth_verifier" => oauth_verifier}
            response = oauth_client.post_form("https://api.twitter.com/oauth/access_token", params).body
           
            puts response
            if response =~ /^oauth_token=([^&]+)&oauth_token_secret=([^&]+)&user_id=([^&]+)&screen_name=([^&]+)&x_auth_expires=([^&]+)$/
                return {
                    "oauth_token" => $1, 
                    "oauth_token_secret" => $2,
                    "user_id" => $3,
                    "screen_name" => $4,
                    "x_auth_expires" => $5
                }
            end
            raise "No oauth token returned"
        end
        
        def rest_client(oauth_token, oauth_verifier)
            oauth = oauth_access_token(oauth_token, oauth_verifier)
            
            return Twitter::Rest::Client.new(
                @consumer_key,
                @consumer_secret,
                oauth["oauth_token"],
                oauth["oauth_token_secret"]
            )
        end
        
        def stream_client(oauth_token, oauth_verifier)
            oauth = oauth_access_token(oauth_token, oauth_verifier)
            
            return Twitter::Stream::Client.new(
                @consumer_key,
                @consumer_secret,
                oauth["oauth_token"],
                oauth["oauth_token_secret"]
            )
        end
    end
end