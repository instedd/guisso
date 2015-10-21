class TrustedRoot < ActiveRecord::Base
  belongs_to :user

  after_save :touch_user_lifespan
  after_destroy :touch_user_lifespan
end
