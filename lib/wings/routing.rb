module Wings
  class Application
    def get_controller_and_action(env)
      _, cont, action, after = env['PATH_INFO'].split('/', 4) # split no more than 4 times. all the rest goes to `after`
      cont = "#{cont.capitalize}Controller"

      [Object.const_get(cont), action]
    end
  end
end