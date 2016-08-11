require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'
require 'erb'
require_relative './session'
require_relative './flash'
require_relative './auth_token'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res)
    @req = req
    @res = res
    @params = req.params

  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise if already_built_response?
    @res['location'] = url
    @res.status = 302
    @already_built_response = true
    session.store_session(@res)
    flash.store_flash(@res)
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise if already_built_response?
    @res['Content-Type'] = content_type
    @res.write(content)
    @already_built_response = true
    session.store_session(@res)
    flash.store_flash(@res)

  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    path = "./views/#{self.class.name.underscore}/#{template_name}.html.erb"
    content = ERB.new(File.read(path)).result(binding)
    render_content(content, 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  def flash
    @flash ||= Flash.new(@req)
  end

  def auth_token
    @auth_token ||= AuthToken.new(@req)
  end

  def form_authenticity_token
    @csrf_token ||= SecureRandom.urlsafe_base64(32)
    auth_token.store_auth_token(@res, @csrf_token)
    @csrf_token
  end

  def check_authenticity_token
    if auth_token.csrf_token != params["authenticity_token"]
      raise "Invalid authenticity token"
      false
    else
      true
    end
  end

  def self.protect_from_forgery
    @@protected = true
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    send(name)
    if @@protected && !req.get?
      if check_authenticity_token
        unless already_built_response?
        render(name)
      end
    end
    else
      render(name) unless already_built_response?
    end
  end
end
