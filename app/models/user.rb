class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :documents, dependent: :destroy
  validates :first_name, :last_name, presence: true, length: { minimum: 2 }
  validates :email, acceptance: { accept: ['erko.salaly@gmail.com', 'vidya1141@gmail.com', 'jellesijm1@gmail.com', 'syilagan@icloud.com'] }
end
