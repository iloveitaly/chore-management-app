class SendChildIntroductionEmail
  include Interactor

  def call
    SendChildEmail.call(
      child: context.child,
      subject: "Welcome to Currency, #{context.child.name}",
      body: <<-EOL
Welcome to Currency!

Currency is a simple solution for tracking your earnings and complete jobs to
earn more money.

View your accounts and available jobs here:

http://#{ENV['APP_DOMAIN']}/app/#/child/#{context.child.id}

- Your friends at Potential
      EOL
    )
  end
end
