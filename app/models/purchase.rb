# == Schema Information
#
# Table name: purchases
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  amount     :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Purchase < ActiveRecord::Base

  belongs_to :user

end
