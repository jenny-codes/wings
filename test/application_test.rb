require_relative 'test_helper'

class ApplicationTest < Minitest::Test
  include Rack::Test::Methods

  def app
    MockApp.new
  end

  def test_request
    get '/index'

    assert last_response.ok?
    assert_equal last_response.body, 'index'
  end
end
