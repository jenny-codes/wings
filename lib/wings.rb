require 'wings/version'
require 'wings/routing'

module Wings
  class Application
    def call(env)
      klass, action = get_controller_and_action(env)
      text = klass.new(env).send(action)
      [200, { 'Content-Type' => 'text/html' }, [text]]
    end
  end

  class Controller
    attr_reader :env

    def initialize(env)
      @env = env
    end
  end
end
