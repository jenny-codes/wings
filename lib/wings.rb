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

    def route(&block)
      @route_obj ||= Route.new
      @route_obj.instance_eval(&block)
    end

    private

    def get_rack_app(env)
      raise 'No routes!' unless @route_obj

      @route_obj.check_url(env['PATH_INFO'], env['REQUEST_METHOD'])
    end
  end
end
