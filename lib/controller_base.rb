require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'
require 'erb'
require_relative './session'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res)
    @req, @res, @params = req, res, req.params
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    @res.redirect(url)

    fail if already_built_response?
    @res.finish
    session.store_session(@res)
    @already_built_response = true
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    @res['CONTENT-TYPE'] = content_type
    @res['CONTENT'] = content


    fail if already_built_response?
    @res.write(content)
    session.store_session(@res)
    @already_built_response = true

  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    file_path = File.expand_path("../views/#{template_name}", __FILE__)
    template = ERB.new(File.read(file_path)).result(binding)
    render_content(template, 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    router = Router.new
    router.run(@req, @res)
  end
end
