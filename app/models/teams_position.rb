class TeamsPosition < ApplicationRecord

	belongs_to :team, optional: true
	belongs_to :position, optional: true
	
end
