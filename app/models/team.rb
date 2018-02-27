class Team < ApplicationRecord

	has_many :users
	belongs_to :leader, class_name: 'User'
	has_many :salevalues, -> {distinct}, through: :leader
	has_many :sales, -> {distinct}, through: :salevalues
	has_many :projects, ->{distinct}, through: :sales

	has_ancestry

	scope :sales_by_upline, ->(id) {  }

	def members
		# including subtree
		user_ids = subtree.pluck(:leader_id)
		User.where(id: user_ids)
	end

	def display_name
		leader.prefered_name
	end

	def self.ransackable_scopes(_auth_object = nil)
	  [:sales_by_upline]
	end

end
