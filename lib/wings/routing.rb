module Wings
  class Application
    def get_controller_and_action(env)
      _, cont, action, after = env['PATH_INFO'].split('/', 4) # split no more than 4 times
      cont = "#{cont.capitalize}Controller"

      [Object.const_get(cont), action] # `const_get` looks up a any name starting with a capital letter
    end
  end
end