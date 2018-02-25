class Team < ApplicationRecord

	has_many :users, dependent: :destroy
	belongs_to :leader, class_name: 'User'

end
