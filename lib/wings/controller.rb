require 'erubis'
require 'wings/file_model'

module Wings
  class Controller
    include Wings::Model

    attr_reader :env, :request, :response

    def initialize(env)
      @env = env
      @request = Rack::Request.new(env)
    end

    def params
      request.params
    end

    def render(*args)
      raise 'You can only render once!' if @response

      @response = fetch_response(fetch_view(*args))
    end

    private

    def controller_name
      klass = self.class.to_s.gsub(/Controller$/, '')
      Wings.to_underscore klass
    end

    def instance_variable_hash
      self.instance_variables.reduce({}) do |memo, var|
        memo[var] = self.instance_variable_get(var)
        memo
      end
    end

    def fetch_view(view_name, locals = {})
      filename = File.join 'app', 'views', controller_name, "#{view_name}.html.erb"
      template = File.read filename
      erb = Erubis::Eruby.new(template)
      erb.result locals.merge(env: env).merge(instance_variable_hash)
    end

    def fetch_response(text, status = 200, **headers)
      headers['Content-Type'] ||= 'text/html'
      Rack::Response.new(text, status, headers)
    end
  end
end
