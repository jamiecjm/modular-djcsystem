class Commission < ApplicationRecord

	belongs_to :project
	has_many :sales

end
