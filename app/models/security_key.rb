# == Schema Information
#
# Table name: security_keys
#
#  id                 :integer          not null, primary key
#  authorization_code :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  user_game_id       :integer
#

class SecurityKey < ActiveRecord::Base

  belongs_to :user_game

  def generate_new_key
    rng_str = ::SecureRandom.base64(20)
    if self.class.exists?(authorization_code: rng_str)
      generate_new_key
    else
      update(authorization_code: rng_str)
      authorization_code
    end
  end

end
