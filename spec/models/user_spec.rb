require 'rails_helper'

RSpec.describe User, type: :model do
  let(:child) { FactoryGirl.create(:child) }

  context 'child login' do
    it 'should not create a family if a child association is specified' do
      user = FactoryGirl.create(:user, child: child)

      expect(user.family_id).to be_nil
      # expect(user.family_id).to eq(child.family.id)
    end
  end

  context 'parent login' do
    it 'should create a family if none is defined and this is the first login' do
      user = FactoryGirl.create(:user)

      expect(user.family_id).to_not be_nil
      expect(user.family.name).to_not be_empty
    end

    it 'should create a user and a family from a email-only signup' do
      user = FactoryGirl.create(:user, child: child, name: nil)

      expect(user.family_id).to be_nil
    end
  end
end
