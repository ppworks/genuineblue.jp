class Connection < ActiveRecord::Base
  extend Enumerize
  PROVIDERS = User.omniauth_providers
  enumerize :provider, in: self::PROVIDERS

  belongs_to :user

  scope :nicknamed, -> (nickname) {
    where("LOWER(connections.nickname) = ?", nickname.try(:downcase))
    .reorder(nil) # ignore ORDER BY when chained first or last
  }
end
