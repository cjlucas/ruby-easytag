require_relative 'spec_helper'

describe EasyTag::Utilities do
  it '#get_int_pair parses int pairs' do
    EasyTag::Utilities.get_int_pair(nil).should     eql([0, 0])
    EasyTag::Utilities.get_int_pair('').should      eql([0, 0])
    EasyTag::Utilities.get_int_pair('3').should     eql([3, 0])
    EasyTag::Utilities.get_int_pair('/9').should    eql([0, 9])
    EasyTag::Utilities.get_int_pair('5/10').should  eql([5, 10])
    EasyTag::Utilities.get_int_pair([8, 21]).should eql([8, 21])
  end

  it '#get_datetime parses dates' do
    date = EasyTag::Utilities.get_datetime('2006')
    date.year.should  be(2006)
    date.month.should be(1)
    date.day.should   be(1)

    date = EasyTag::Utilities.get_datetime('1955-05')
    date.year.should  be(1955)
    date.month.should be(5)
    date.day.should   be(1)

    date = EasyTag::Utilities.get_datetime('2012-12-07T08:00:00Z')
    date.year.should  be(2012)
    date.month.should be(12)
    date.day.should   be(7)

    date = EasyTag::Utilities.get_datetime('19880711')
    date.year.should  be(1988)
    date.month.should be(11)
    date.day.should   be(7)

    date = EasyTag::Utilities.get_datetime('2006-99-99')
    date.year.should  be(2006)
    date.month.should be(1)
    date.day.should   be(1)

    date = EasyTag::Utilities.get_datetime('2000-00-00')
    date.year.should  be(2000)
    date.month.should be(1)
    date.day.should   be(1)

    date = EasyTag::Utilities.get_datetime('')
    date.should be(nil)
  end
end