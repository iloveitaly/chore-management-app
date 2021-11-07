namespace :currency do
  task weekly_report: :environment do
    if Date.today.wday != 6
      Rails.logger.info "Not saturday, skipping weekly report"
      next
    end

    SendChildAccountUpdates.call
  end

  task interest: :environment do
    if DateTime.now.day != 1
      Rails.logger.info "Not first day of the month, skipping"
      next
    end

    # TODO https://github.com/iloveitaly/family-currency/issues/23
    target_month = DateTime.now.prev_month

    Account.all.each do |account|
      ApplyAccountInterest.call(
        target_month: target_month,
        account: account
      )
    end
  end

  task bootstrap: :environment do |t|
    usd = Currency.find_or_initialize_by(name: 'USD')
    usd.monetary = true
    usd.icon = '$'
    usd.save!

    cad = Currency.find_or_initialize_by(name: 'CAD')
    cad.monetary = true
    cad.icon = 'C$'
    cad.save!

    screen_time = Currency.find_or_initialize_by(name: 'Screen Time')
    screen_time.icon = 'ion-ios-monitor'
    screen_time.zero_decimal = true
    screen_time.save!

    time = Currency.find_or_initialize_by(name: 'Time')
    time.icon = 'ion-clock'
    time.zero_decimal = true
    time.save!

    Account.where(currency_id: nil).each do |account|
      account.currency = usd
      account.save!
    end
  end
end
