require_relative '../test_helper'

module Wings
  class RoutingTest < Minitest::Test
    def test_get_controller_and_action
      mock_env = {
        'PATH_INFO' => '/mock/index/random_str'
      }
      cont, action = Application.new.get_controller_and_action(mock_env)
      assert_equal MockController, cont
      assert_equal 'index', action
    end
  end
end