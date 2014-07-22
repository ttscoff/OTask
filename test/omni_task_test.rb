require "minitest/autorun"
require "omni_task"

class TestOtask < MiniTest::Unit::TestCase
  def test_parsed_options_returns_true_for_valid_arguments
    task = OmniTask.new(["-g"], '')
    assert_equal true, task.send(:parsed_options?)
  end
end
