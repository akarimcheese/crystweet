# crystal_twitter

Writing a Twitter API Wrapper for the purposes of application-specific queries and streaming. Mainly for my own use.
There are better Twitter libraries out there for user-specific queries, such as https://github.com/sferik/twitter-crystal.

# TODO

- Figure out how crystal library versions work
- Factor out core "cursor" iterator functionality into an interface/class, make individual subclasses/structs for individual cursors such as user id cursors and what not
- Ya know..., tests
- Verbose mode

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  crystal_twitter:
    github: akarimcheese/crystal_twitter
```

## Usage

```crystal
require "crystal_twitter"
```

Creating a Stream Client

```crystal
Twitter::Stream::Client.new(
  ENV["TWITTER_CONSUMER_KEY"], 
  ENV["TWITTER_CONSUMER_SECRET"], 
  ENV["TWITTER_ACCESS_TOKEN"],
  ENV["TWITTER_ACCESS_SECRET"]
)
```

Start a stream

```crystal
client.stream(track: ["WWE", "John Cena"]) do |tweet|
  # do something with Twitter::Response::Tweet instance
end
```

Creating a REST Client

```crystal
client = Twitter::Rest::Client.new(
  ENV["TWITTER_CONSUMER_KEY"], 
  ENV["TWITTER_CONSUMER_SECRET"], 
  ENV["TWITTER_ACCESS_TOKEN"],
  ENV["TWITTER_ACCESS_SECRET"]
)
```

Having REST Client sleep on rate limit
```crystal
client.persistent
```

Finding follower ids for a user as an iterator (lazy query)
```crystal
ids = client.user("JohnCena").followers_ids

# OR

ids = Twitter::REST::User.new(client, "John Cena").follower_ids
```

Get a user id iterator as an array (eager query)
```crystal
ids = ids.to_a
```

Convert array of user ids to array of fully hydrated users
```crystal
users = client.user_lookup(ids).lookup_users

# OR

users = Twitter::REST::UserLookup.new(client, ids).lookup_users
```

TODO: Convert iterator of user ids to fully hydrated users

## Development

TODO: Write development instructions here

## Contributing

1. Fork it ( https://github.com/akarimcheese/crystal_twitter/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [akarimcheese](https://github.com/[akarimcheese]) Ayman Karim - creator, maintainer
