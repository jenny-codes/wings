require 'erubis'

module Wings
  class Controller
    attr_reader :env

    def initialize(env)
      @env = env
    end

    def render(view_name, locals = {})
      filename = File.join 'app', 'views', controller_name, "#{view_name}.html.erb"
      template = File.read filename
      erb = Erubis::Eruby.new(template)
      erb.result locals.merge(env: env).merge(instance_variable_hash)
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
  end
end