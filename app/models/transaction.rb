class Transaction < ApplicationRecord
  belongs_to :account, touch: true
  has_one :currency, through: :account

  scope :interest_payments, -> { where(transaction_type: :interest) }

  validates :amount, presence: true, numericality: true
  validates :account, presence: true
end

class TransactionSerializer < ActiveModel::Serializer
  attributes :id, :description, :amount, :created_at, :payee, :payor, :type,
             :account_id, :currency_id

  # TODO there's got to be a cleaner way to pull the ID without writing additional code
  def currency_id
    object.currency.id
  end

  def type
    if object.transaction_type.present?
      object.transaction_type
    else
      object.amount >= 0 ? 'income' : 'expense'
    end
  end
end
