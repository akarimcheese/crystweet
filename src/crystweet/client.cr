require "http/client"
require "oauth"

module Twitter
    abstract class Client
        property client
        property consumer_key, consumer_secret, access_token, access_secret
        
        def initialize(@consumer_key : String, @consumer_secret : String, @access_token : String, @access_secret : String)
            @client = HTTP::Client.new(base_url, tls: true)
            oauth()
        end
        
        abstract def base_url
        
        abstract def api_version
        
        def oauth
            consumer = OAuth::Consumer.new("https://#{base_url()}/#{api_version()}/", @consumer_key, @consumer_secret)
            oauth_access_token = OAuth::AccessToken.new(@access_token, @access_secret)
            @client = HTTP::Client.new(base_url, tls: true)
            consumer.authenticate(@client, oauth_access_token)
        end
    end
end