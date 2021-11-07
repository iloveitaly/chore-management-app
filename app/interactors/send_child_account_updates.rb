class SendChildAccountUpdates
  include Interactor

  def call
    Child.where(email_enabled: true).where.not(email: nil).each do |child|
      if child.account_update_schedule.occurring_between?(DateTime.now.at_beginning_of_day.to_time, DateTime.now.at_end_of_day.to_time)
        SendChildEmail.call(
          child: child,
          subject: "Your latest account updates",
          body: generate_body(child)
        )
      end
    end
  end

  private

    def generate_body(child)
      current_balance = child.balance_for_currency('USD')
      previous_balance = child.balance_for_currency_at_time('USD', DateTime.now - 7.days)

      balance_change = current_balance - previous_balance

      <<-EOL
Hey #{child.name},

Your net worth changed by #{balance_change} over this past week.

View your balance in real-time here:

http://#{ENV['APP_DOMAIN']}/app/#/child/#{child.id}

- Your friends at Potential
EOL
    end
end
