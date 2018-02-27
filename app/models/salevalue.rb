class Salevalue < ApplicationRecord

	belongs_to :user
	has_one :team, through: :user
	belongs_to :sale
	has_one :project, through: :sale
	has_one :unit, through: :sale
	has_one :commission, through: :sale

	validates :percentage, presence: true
	validates :other_user, presence: true, if: proc { user_id.blank? }

	scope :other_team, -> {where.not(other_user: nil)}
	scope :not_cancelled, -> { search(sale_status_not_eq: 2).result }
	scope :cancelled, -> { search(sale_status_eq: 2).result }

end
