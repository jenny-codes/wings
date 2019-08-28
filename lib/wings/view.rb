require 'erubis'

module Wings
  class View
    attr_reader :text, :status, :headers

    def initialize(attrs)
      @env           = attrs[:env]
      @headers       = attrs[:headers] || {}
      @template      = attrs[:template]
      @local_vars    = attrs[:local_vars] || {}
      @controller    = attrs[:controller]
      @instance_vars = attrs[:instance_vars] || {}

      @text = get_text
      @status = attrs[:status] || 200
      @headers['Content-Type'] ||= 'text/html'
    end

    private

    def get_text
      template = File.read(File.join('app', 'views', @controller, "#{@template}.html.erb"))
      erb = Erubis::Eruby.new(template)
      erb.result additional_variables
    end

    def additional_variables
      Hash.new
       .merge(env: @env)
       .merge(@local_vars)
       .merge(@instance_vars)
    end
  end
end