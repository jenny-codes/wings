require_relative '../test_helper'

module Wings
  class UtilTest < Minitest::Test
    def test_to_underscore
      test_data = {
        'TwoWords'              => 'two_words',
        'With3Number'           => 'with3_number',
        'With::Scope'           => 'with/scope',
        'WithNumber3::AndScope' => 'with_number3/and_scope',
      }

      test_data.each do |key, value|
        expected_transformed_value = Wings.to_underscore(key)
        assert_equal expected_transformed_value, value
      end
    end
  end
end