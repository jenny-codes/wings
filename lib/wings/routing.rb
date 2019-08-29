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
        match actions[action][:path], "#{obj}##{action}", verb: actions[action][:verb]
      end
    elsif options[:except]
      actions.each do |action, value|
        next if options[:except].include?(action)

        match value[:path], "#{obj}##{action}", verb: value[:verb]
      end
    else
      actions.each do |action, value|
        match value[:path], "#{obj}##{action}", verb: value[:verb]
      end
    end
  end

  def match(url, *args)
    raise 'Arguments should be no more than 2' if args.count >= 2

    options = args.last if args.last.is_a?(Hash)
    dest    = args.first if args.first.is_a?(String)
    parts   = url.split('/').reject { |pt| pt.empty? }
    vars    = []

    regex_parts = parts.map do |part|
      if part[0] == ':'
        vars << part[1..-1]
        '([a-zA-Z0-9]+)'
      elsif part[0] == '*'
        vars << part[1..-1]
        '(.*)'
      else
        part
      end
    end

    regex = regex_parts.join('/')
    @rules.push(
      {
        regex:   Regexp.new("^/#{regex}/?$"),
        options: options,
        vars:    vars,
        dest:    dest,
      }
    )
  end

  def root(dest)
    @rules.push(
      {
        regex: Regexp.new("^/?$"),
        dest:  dest,
      }
    )
  end

  def check_url(url)
    @rules.each do |r|
      m = r[:regex].match(url)
      next unless m

      params = r[:options] ? r[:options].dup : Hash.new

      if vars = r[:vars]
        vars.each_with_index do |v, i|
          params[v] = m.captures[i]
        end
      end

      dest = r[:dest] || "#{params['controller']}##{params['action']}"
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