$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require 'rr'
require 'pry'
require 'wings'
require 'rack/test'
require 'minitest/autorun'

class MockApp < Wings::Application
  def get_controller_and_action(env)
    [MockController, 'index']
  end
end

class MockController < Wings::Controller
  def index
    'index' # not rendering a view
  end
end