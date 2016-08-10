require 'pathname'

class Static

  TYPES = { image: %w(jpg jpeg gif png bmp), audio: %w(mp3), video: %w(mp4), text: %w(plain html)}

  attr_reader :app

  def initialize(app)
    @app = app
  end

  def call(env)
    if env['PATH_INFO'].match(/^(\/public)/)
      construct_response(env)
    else
      @app.call(env)
    end
  end

  private

  def construct_response(env)
    req = Rack::Request.new(env)
    res = Rack::Response.new
    path = "./" + "#{req.path_info}"
    pathname = Pathname.new(path)
    if pathname.exist?
      file = File::read(path)
      res.write(file)

      match_data = path.match(/\.(\w+)/)
      file_extension = match_data[1]

      content_type = TYPES.keys.select { |type| TYPES[type].include?(file_extension)}[0]

      res['Content-Type'] = "#{content_type.to_s}/#{file_extension}"
      res.finish
    else
      res.status = 404
      res.finish
    end
  end

end
