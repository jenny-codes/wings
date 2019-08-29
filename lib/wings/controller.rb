require 'wings/view'
require 'wings/file_model'

module Wings
  class Controller
    include Wings::Model

    attr_reader :env, :request, :params, :response

    # Respond to Rack
    # The action will be used like a Rack app
    def self.action(act, rp = {})
      proc { |e| self.new(e).dispatch(act, rp) }
    end

    def initialize(env)
      @env     = env
      @request = Rack::Request.new(env)
      @params  = request.params
    end

    def dispatch(action, routing_params = {})
      @params.merge!(routing_params)

      self.send(action)

      if response
        [response.status, response.headers, response.body]
      else
        render(action)
      end
    end

    # [options for render]
    # locals:  local variables
    # status:  status code
    # headers: headers
    def render(template, **opts)
      raise 'You can only render once!' if @response

      v = View.new(params_for_view(template, opts))
      @response = Rack::Response.new(v.text, v.status, v.headers)
    end

    private

    def params_for_view(template, opts = {})
      {
        env:           env,
        status:        opts[:status],
        headers:       opts[:headers],
        template:      template,
        local_vars:    opts[:locals],
        controller:    controller_name,
        instance_vars: instance_variable_hash,
      }
    end

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
  end
end
