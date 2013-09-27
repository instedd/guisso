class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  has_many :identities, dependent: :destroy
  has_many :trusted_roots, dependent: :destroy

  def name_with_email
    if name.present?
      "#{name} <#{email}>"
    else
      email
    end
  end
end
