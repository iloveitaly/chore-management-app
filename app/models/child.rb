class Child < ApplicationRecord
  serialize :account_update_schedule, ::IceCube::Schedule

  belongs_to :family
  has_many :chores
  has_many :accounts
  has_one :user

  before_create do
    # NOTE default reporting schedule, weekly saturday @ 5am
    self.update_email_schedule('weekly', 1)
  end

  after_save do
    if email_changed? && email.present?
      SendChildIntroductionEmail.call(child: self)
    end
  end

  # TODO there's got to be a cleaner way to represent this
  def update_email_schedule(frequency, day)
    day = day.to_i

    self.account_update_schedule = IceCube::Schedule.new((DateTime.now.beginning_of_week.end_of_day - 1.day).to_time)
    self.account_update_schedule.add_recurrence_rule(
      if frequency == 'weekly'
        IceCube::Rule.weekly.day(day)
      else
        IceCube::Rule.monthly.day_of_month(day)
      end
    )
  end

  def default_currency
    account_currencies = accounts.map(&:currency).select(&:monetary?)
    default_currency = Currency.account_default

    Currency.monetary.inject(0) do |c, currency|
      count = account_currencies.count(currency)

      if count > c
        default_currency = currency
        c = count
      end

      c
    end

    default_currency
  end

  def balance_by_currency
    self.accounts.map(&:currency).uniq.map do |currency|
      {
        currency: currency.name,
        currency_id: currency.id,
        balance: balance_for_currency(currency)
      }
    end
  end

  def balance_for_currency(currency = 'USD')
    if currency.is_a?(String)
      currency = Currency.find_by(name: currency)
    end

    accounts.select { |a| a.currency == currency }
      .map(&:balance)
      .sum
  end

  def balance_for_currency_at_time(currency = 'USD', time)
    accounts.select { |a| a.currency.name == currency }
      .map { |a| a.balance_at_time(time) }
      .sum
  end
end

class ChildSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :updated_at, :created_at, :family, :email_enabled,
             :email_frequency, :email_day, :has_user_account, :default_currency_id,
             :split_earnings, :count_of_accounts, :balance_by_currency

  has_many :accounts
  has_many :chores

  def default_currency_id
    object.default_currency.id
  end

  def has_user_account
    object.user.present?
  end

  def count_of_accounts
    object.accounts.count
  end

  # TODO clean up this `ice_cube` stuff; super messy

  def email_frequency
    email_schedule_rule.class == IceCube::WeeklyRule ? 'weekly' : 'monthly'
  end

  def email_day
    if email_frequency == 'monthly'
      email_schedule_rule.
        validations[:day_of_month].
        first.
        day
    else
      email_schedule_rule.
        validations[:day].
        first.
        day
    end
  end

  protected

    def email_schedule_rule
      object.
        account_update_schedule.
        recurrence_rules.
        first
    end
end
