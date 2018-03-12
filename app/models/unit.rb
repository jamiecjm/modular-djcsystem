# == Schema Information
#
# Table name: units
#
#  id              :integer          not null, primary key
#  unit_no         :string
#  size            :integer
#  nett_price      :float
#  spa_price       :float
#  comm            :float
#  comm_percentage :float
#  project_id      :integer
#  sale_id         :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_units_on_id_and_project_id  (id,project_id)
#  index_units_on_id_and_sale_id     (id,sale_id)
#

class Unit < ApplicationRecord

	belongs_to :project, optional: true
	has_one :sale

	def display_name
		unit_no
	end

end
