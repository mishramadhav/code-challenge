class Company < ApplicationRecord
  has_rich_text :description

  ALLOWED_EMAIL_DOMAINS = %w(getmainstreet.com)
  EMAIL_REGEX = /^[a-zA-Z0-9\-\._%\+]{1,256}@$/

  validate :validate_email_user_name, if: -> { email.present? }
  validate :validate_email_domain, if: -> { email.present? }
  validate :validate_zip_code
  before_save { self.email = email.downcase }
  before_save :update_city_state, if: -> { :zip_code_changed? }

  private

  def validate_email_domain
    return if ALLOWED_EMAIL_DOMAINS.include? email_domain

    errors.add(
      :email,
      message: I18n.t(
        'error_message.email.invalid_domain',
        allowed_domains: ALLOWED_EMAIL_DOMAINS.join(','),
      ),
    )
  end

  def email_domain
    email.to_s.split('@').last.downcase
  end

  def validate_email_user_name
    user_name = email.gsub(email_domain, "")
    return if user_name.match(EMAIL_REGEX).present?

    errors.add(:email, message: I18n.t('error_message.email.invalid_email'))
  end

  def validate_zip_code
    return if ZipCodes.identify(zip_code).present?

    errors.add(:zip_code, message: I18n.t('error_message.zip_code.empty'))
  end

  def update_city_state
    zip_code_data = ZipCodes.identify(zip_code) || {}
    self.city = zip_code_data[:city]
    self.state = zip_code_data[:state_code]
  end
end
