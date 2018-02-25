class Sale < ApplicationRecord

	has_many :salevalues, dependent: :destroy
	has_many :users, through: :salevalues
	has_many :teams, through: :users
	belongs_to :project
	belongs_to :unit
	belongs_to :commission

end
