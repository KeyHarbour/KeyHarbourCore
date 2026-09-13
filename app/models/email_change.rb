class EmailChange < ApplicationRecord
  belongs_to :user

  generates_token_for :email_change, expires_in: 24.hours do
    user.email_address
  end
end
