class Account < ApplicationRecord
  belongs_to :currency
  belongs_to :family
  belongs_to :child

  default_scope { where(deleted_at: nil) }

  has_many :transactions, -> { order(created_at: :desc) }

  acts_as_list scope: :family, top_of_list: 0

  validates :name, presence: true

  def split_income?
    self.child.present? && self.child.split_earnings && self.currency == self.child.default_currency
  end

  def balance
    self.transactions.sum(:amount)
  end

  def balance_at_time(time)
    self.transactions
      .where('created_at <= ?', time)
      .sum(:amount)
  end
end

class AccountSerializer < ActiveModel::Serializer
  attributes :id, :name, :balance, :updated_at, :currency_id, :interest_rate,
             :position, :child_id, :split_percentage

  attribute :split_income?, key: :split_income
end
