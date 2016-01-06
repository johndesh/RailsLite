class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern, @http_method, @controller_class, @action_name =
    pattern, http_method, controller_class, action_name

  end

  # checks if pattern matches path and method matches request method
  def matches?(req)
    pattern =~ req.path && http_method == req.request_method.downcase.to_sym
  end

  # use pattern to pull out route params (save for later?)
  # instantiate controller and call controller action
  def run(req, res)
    route_params = {}
    matches = pattern.match(req.path)
    pattern.names.each do |capt|
      route_params[capt] = matches[capt]
    end

    controller = controller_class.constantize.new(req, res)
    controller.send(action_name)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  # simply adds a new route to the list of routes
  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  # evaluate the proc in the context of the instance
  # for syntactic sugar :)
  def draw(&proc)

  end

  # make each of these methods that
  # when called add route
  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, method, controller_class, action_name|
      add_route(pattern, method, controller_class, action_name)
    end
  end

  # should return the route that matches this request
  def match(req)
    Route.All.find { |route| route.matches?(req) }
  end

  # either throw 404 or call run on a matched route
  def run(req, res)
    matched_req = match(req)
    if matched_req
      matched_req.run(req, res)
    else
      res = Rack::Response.new([404, {'Content-Type' => 'text/html'}, ['404 NOT FOUND']])
      res.finish
    end
  end
end
