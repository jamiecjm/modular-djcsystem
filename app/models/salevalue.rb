class Salevalue < ApplicationRecord

	belongs_to :user
	has_one :team, through: :user
	belongs_to :sale
	has_one :project, through: :sale
	has_one :unit, through: :sale
	has_one :commission, through: :sale

end
