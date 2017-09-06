module Twitter
    class EndpointMapping
        def initialize
            @mapping = {
                :following => "friends/ids.json?",
                :followers => "followers/ids.json?",
                :userSearch => "users/search.json?"
            }
        end
        
        def [](endpoint)
            @mapping[endpoint]
        end
    end
end