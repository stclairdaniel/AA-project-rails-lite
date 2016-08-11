require 'json'

class AuthToken

  attr_reader :csrf_token

  def initialize(req)
    csrf_token = req.cookies["authenticity_token"]
    if csrf_token
      @csrf_token = csrf_token
    else
      @csrf_token = ""
    end
  end

  def [](key)
    @csrf_token[key]
  end

  def []=(key, val)
    @csrf_token[key] = val
  end

  def store_auth_token(res, csrf_token)
    p csrf_token
    res.set_cookie("authenticity_token", {path: '/', value: csrf_token})
  end
end
