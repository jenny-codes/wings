require 'wings/util'
require 'wings/version'
require 'wings/routing'
require 'wings/controller'
require 'wings/file_model'
require 'wings/dependencies'

module Wings
  class Application
    def call(env)
      klass, action = get_controller_and_action(env)
      text = klass.new(env).send(action)
      [200, { 'Content-Type' => 'text/html' }, [text]]
    end
  end
end
