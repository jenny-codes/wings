require 'wings/version'

module Wings
  class Application
    def call(env)
      `echo debug > debug.txt`
      [200, { 'Content-Type' => 'text/html' }, ['Ruby on Wings rocking!']]
    end
  end
end
