require 'spec_helper'
require 'rails_helper'

describe 'User' do
  let(:user) { build(:general_user) }

  describe "valid usernames" do
    valid_usernames = %w(
      ryuzee
      ryuzee-1234
      RYUZEE
      ryu
    )
    it { expect(user).to allow_value(*valid_usernames).for(:username) }
  end

  describe "invalid usernames" do
    invalid_usernames = [
      'ryuzee@example.com',
      'search',
      '-ryuzee',
      'ryu zee',
      'ry',
      'ryuzee789012345678901234567890123',
    ]
    it { expect(user).not_to allow_value(*invalid_usernames).for(:username) }
  end
end
