require 'json'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    cookies = req.cookies["_rails_lite_app"]
    @session = cookies.nil? ? {} : JSON.parse(cookies)
  end

  def [](key)
    @session[key]
  end

  def []=(key, val)
    @session[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    options = { path: '/', value: @session.to_json }
    res.set_cookie('_rails_lite_app', options)
  end
end
