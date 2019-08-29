module Wings
  class Application
    def route(&block)
      @route_obj ||= RouteObject.new
      @route_obj.instance_eval(&block)
    end

    def get_rack_app(env)
      raise 'No routes!' unless @route_obj

      @route_obj.check_url(env['PATH_INFO'])
    end
  end
end

class RouteObject
  def initialize
    @rules = []
  end

  # actions: `index`, `new`, `create`, `show`, `edit`, `update`, `destroy`
  def resources(obj, **options)
    actions = {
      index:   { path: "#{obj}"                    },
      new:     { path: "#{obj}/new"                },
      create:  { path: "#{obj}", verb: :post       },
      show:    { path: "#{obj}/:id"                },
      edit:    { path: "#{obj}/:id/edit"           },
      update:  { path: "#{obj}/:id", verb: :patch  },
      destroy: { path: "#{obj}/:id", verb: :delete },
    }

    if options[:only]
      options[:only].each do |action|
        match actions[action][:path], to: "#{obj}##{action}", verb: actions[action][:verb]
      end
    elsif options[:except]
      actions.each do |action, value|
        next if options[:except].include?(action)

        match value[:path], to: "#{obj}##{action}", verb: value[:verb]
      end
    else
      actions.each do |action, value|
        match value[:path], to: "#{obj}##{action}", verb: value[:verb]
      end
    end
  end

  def match(url, **opts)
    vars  = []
    regex = url.split('/')
               .reject { |pt| pt.empty? }
               .map do |part|
                  if part[0] == ':'
                    vars << part[1..-1]
                    '([a-zA-Z0-9]+)'
                  elsif part[0] == '*'
                    vars << part[1..-1]
                    '(.*)'
                  else
                    part
                  end
               end.join('/')

    @rules.push(
      {
        regex:   Regexp.new("^/#{regex}/?$"),
        options: opts,
        vars:    vars,
      }
    )
  end

  def root(dest)
    @rules.push(
      {
        regex:   Regexp.new("^/?$"),
        options: { to: dest },
      }
    )
  end

  def check_url(url, **opts)
    @rules.each do |r|
      m = r[:regex].match(url)
      next unless m

      params = r[:options] ? r[:options].dup : Hash.new

      if vars = r[:vars]
        vars.each_with_index do |v, i|
          params[v] = m.captures[i]
        end
      end

      dest = params[:to] || "#{params['controller']}##{params['action']}"
      return get_destination(dest, params)
    end

    nil
  end

  private

  def get_destination(dest, routing_params = {})
    return dest if dest.respond_to?(:call)

    if dest =~ /^([^#]+)#([^#]+)$/
      cont = Object.const_get("#{$1.capitalize}Controller")
      return cont.action($2, routing_params)
    end

    raise "No destination: #{dest.inspect}!"
  end
end