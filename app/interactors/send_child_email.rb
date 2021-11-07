class SendChildEmail
  include Interactor

  def call
    if ENV['MAILGUN_API_KEY'].blank?
      Rails.logger.info "Send email: #{context.body}"
      return
    end

    response = RestClient.post("https://api:#{ENV['MAILGUN_API_KEY']}@api.mailgun.net/v3/mg.currency.family/messages",
      :from => 'support@currency.family',
      :to => context.child.email,
      :cc => parents_emails,
      :bcc => 'dev-bots@potential.family',

      :subject => context.subject,
      :text => context.body
    )

    if response.code != 200
      raise "error sending email"
    end
  rescue RestClient::BadRequest => e
    # TODO by default the rest client exception does not include the error from mailgun!!
    e.message += e.http_body

    Rollbar.error(e)
  end

  protected

    def parents_emails
      context.
        child.
        family.
        parents.
        compact.
        map(&:email).
        join(',')
    end

end
