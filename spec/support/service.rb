module ServiceSpecHelpers
  module ClassMethods
    def basic_family
      let!(:child) { FactoryGirl.create(:child) }
      let(:family) { child.family }
      let(:user) { family.parents.first }
    end
  end

  def parsed_response
    JSON.parse(response.body)
  end
end

RSpec.configure do |config|
  config.include ServiceSpecHelpers, type: :controller
  config.extend ServiceSpecHelpers::ClassMethods, type: :controller
end
