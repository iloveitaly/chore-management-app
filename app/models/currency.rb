class Currency < ApplicationRecord
  scope :monetary, -> { where(monetary: true) }

  def self.account_default
    self.find_by(name: 'USD')
  end
end

class CurrencySerializer < ActiveModel::Serializer
  attributes :id, :name, :icon
  attribute :zero_decimal, key: 'zeroDecimal'
  attribute :monetary
end
