class TokenAccount < Token
  validate :ensure_correct_scopable_type
  validates :environment, absence: true

  def account
    scopable
  end

  private

  # def self.check(token_str)
  #   token = TokenAccount.find_by_token_for(:statefile, token_str)
  #   return nil unless token && token.expiration > Time.current
    
  #   token
  # end

  def ensure_correct_scopable_type
    unless scopable.is_a?(Account)
      errors.add(:scopable, "must be an Account")
    end
  end  
end
