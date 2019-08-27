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
      erb.result locals.merge(env: env)
    end

    private

    def controller_name
      klass = self.class.to_s.gsub(/Controller$/, '')
      Wings.to_underscore klass
    end
  end
end
