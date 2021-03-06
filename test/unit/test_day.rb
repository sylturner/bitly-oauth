require 'test_helper'

class TestDay < Test::Unit::TestCase
  context 'a day' do
    setup do
      @day = BitlyOAuth::Day.new
    end
    [:clicks, :day_start].each do |method|
      should "respond to #{method}" do
        assert_respond_to @day, method
      end
    end
    should 'set clicks when initializing' do
      day = BitlyOAuth::Day.new('clicks' => 12)
      assert_equal 12, day.clicks
    end
    should 'set day to a time object when initialising' do
      day = BitlyOAuth::Day.new('day_start' => 1290488400)
      assert_equal Time.parse('2010-11-23 05:00:00 +0000'), day.day_start
    end
  end
end
