require 'wings/util'
require 'wings/version'
require 'wings/routing'
require 'wings/controller'
require 'wings/file_model'
require 'wings/dependencies'

module Wings
  class Application
    def call(env)
      rack_app = get_rack_app(env)
      rack_app.call(env)
    end
  end
end
