# == Schema Information
#
# Table name: overriding_commissions
#
#  id           :bigint(8)        not null, primary key
#  team_id      :integer
#  salevalue_id :integer
#  override     :float
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_overriding_commissions_on_salevalue_id              (salevalue_id)
#  index_overriding_commissions_on_team_id                   (team_id)
#  index_overriding_commissions_on_team_id_and_salevalue_id  (team_id,salevalue_id) UNIQUE
#

class OverridingCommission < ApplicationRecord
	belongs_to :team
	belongs_to :salevalue, optional: true
end
