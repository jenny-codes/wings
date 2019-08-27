require_relative 'test_helper'

class WingsTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Wings::VERSION
  end
end
