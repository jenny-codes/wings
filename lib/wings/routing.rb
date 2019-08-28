module Wings
  class Application
    def get_controller_and_action(env, &block)
      _, cont, action, _ = env['PATH_INFO'].split('/', 4) # split no more than 4 times. all the rest goes to `after`
      cont = "#{cont.capitalize}Controller"

      block.call(Object.const_get(cont), action)
    end
  end
end