require 'wings/util'
require 'wings/version'
require 'wings/routing'
require 'wings/controller'
require 'wings/file_model'
require 'wings/dependencies'

module Wings
  class Application
    def call(env)
      get_controller_and_action(env) do |controller, action|
        instance = controller.new(env)
        instance.send(action)
        if r = instance.response
          [r.status, r.headers, r.body]
        else
          instance.render(action)
        end
      end
    end
  end
end
