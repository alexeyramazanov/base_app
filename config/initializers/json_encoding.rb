# Default JSON time format to use ISO8601 to match Heroku API Design Guide.
# ActiveSupport::JSON::Encoding.time_precision => 3
# Time.now.utc.to_json => 2016-04-28T19:31:07.678Z
# ActiveSupport::JSON::Encoding.time_precision = 0
# Time.now.utc.to_json => 2016-04-28T19:31:49Z
ActiveSupport::JSON::Encoding.time_precision = 0
