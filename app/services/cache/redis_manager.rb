require 'redis'

class RedisManager
  def initialize
    @redis = Redis.new(url: 'redis://redis:6379')
  end

  def set_key_value_pair(key, value)
    @redis.set(key, value)
  end

  def get_value(key)
    @redis.get(key)
  end
end