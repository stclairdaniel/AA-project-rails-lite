require 'erb'

class ShowExceptions

  attr_reader :app

  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      @app.call(env)
    rescue => e
      render_exception(e)
    end
  end

  private

  def render_exception(e)
    @error_message = e.to_s
    @backtrace = e.backtrace
    content = ERB.new(File.read("./lib/templates/rescue.html.erb")).result(binding)
    response = ['500', {'Content-type' => 'text/html'}, [content]]
  end

end
