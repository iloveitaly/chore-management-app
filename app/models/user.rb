class User < ApplicationRecord
  devise :omniauthable,
         :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable

  # note that this include statement comes AFTER the devise block above
  include DeviseTokenAuth::Concerns::User

  has_many :accounts, through: :family

  belongs_to :family
  belongs_to :child

  before_save do
    if new_record? && self.family.blank? && self.child.blank?
      self.family = Family.create!(
        name: ((self.nickname || self.name).split(" ").last rescue nil)
      )
    end
  end

  # def token_validation_response
  #   self.as_json(except: [
  #     :tokens, :created_at, :updated_at
  #   ])
  # end

  # def self.from_omniauth(auth)
  #    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
  #      user.provider = auth.provider
  #      user.uid = auth.uid
  #      user.email = auth.info.email
  #      user.password = Devise.friendly_token[0,20]
  #    end
  #  end
end
