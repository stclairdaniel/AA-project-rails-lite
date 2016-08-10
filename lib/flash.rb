require 'json'

class Flash
  def initialize(req)
    cookie = req.cookies["_rails_lite_app_flash"]

    if cookie
      @now_cookie = JSON.parse(cookie)
    else
      @now_cookie = {}
    end

    @cookie = {}

  end

  def [](key)
    @now_cookie[key] || @cookie[key]
  end

  def []=(key, val)
    @cookie[key] = val
  end

  def store_flash(res)
    res.set_cookie("_rails_lite_app_flash", {path: '/', value: @cookie.to_json})
  end

  def now
    @now_cookie
  end

end
