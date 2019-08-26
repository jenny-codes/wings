require_relative 'test_helper'

class ApplicationTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Wings::Application.new
  end

  def test_request
    get '/'

    assert last_response.ok?
    assert_equal last_response.body, 'Ruby on Wings rocking!'
  end
end
