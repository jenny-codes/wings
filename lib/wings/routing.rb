module Wings
  class Route
    def initialize
      @rules = []
    end

    def root(dest)
      @rules.push(
        {
          regex:   Regexp.new("^/?$"),
          options: { to: dest, verb: :GET },
        }
      )
    end

    # actions: `index`, `new`, `create`, `show`, `edit`, `update`, `destroy`
    def resources(obj, **options)
      actions = {
        index:   { path: "#{obj}" },
        new:     { path: "#{obj}/new" },
        create:  { path: "#{obj}", verb: :POST },
        show:    { path: "#{obj}/:id" },
        edit:    { path: "#{obj}/:id/edit" },
        update:  { path: "#{obj}/:id", verb: :PATCH },
        destroy: { path: "#{obj}/:id", verb: :DELETE },
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

      opts[:verb] ||= :GET

      @rules.push(
        {
          regex:   Regexp.new("^/#{regex}/?$"),
          options: opts,
          vars:    vars,
        }
      )
    end

    def check_url(url, req_method)
      (@rules + default_matches).each do |r|
        m      = r[:regex].match(url)
        params = r[:options].dup

        next unless m
        next unless req_method == params[:verb].to_s

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

    def default_matches
      [
        {
          regex:   Regexp.new('^/([a-zA-Z0-9]+)/([a-zA-Z0-9]+)/([a-zA-Z0-9]+)/?$'),
          vars:    %w( controller id action ),
          options: { verb: :GET },
        },
        {
          regex:   Regexp.new('^/([a-zA-Z0-9]+)/([a-zA-Z0-9]+)/?$'),
          vars:    %w( controller id ),
          options: { verb: :GET, 'action' => 'show' },
        },
        {
          regex:   Regexp.new('^/([a-zA-Z0-9]+)/?$'),
          vars:    %w( controller ),
          options: { verb: :GET, 'action' => 'index' },
        },
      ]
    end

    def get_destination(dest, routing_params = {})
      return dest if dest.respond_to?(:call)

      if dest =~ /^([^#]+)#([^#]+)$/
        cont = Object.const_get("#{$1.capitalize}Controller")
        return cont.action($2, routing_params)
      end

      raise "No destination: #{dest.inspect}!"
    end
  end
end