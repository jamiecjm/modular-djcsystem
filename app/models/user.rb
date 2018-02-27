class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, 
         :recoverable, :rememberable, :trackable, :validatable

    belongs_to :team
	has_one :pseudo_team, class_name: 'Team', foreign_key: :leader_id
	has_many :salevalues, dependent: :destroy
	has_many :sales, ->{distinct}, through: :salevalues
	has_many :projects, ->{distinct}, through: :sales
	has_many :units, ->{distinct}, through: :sales

	has_ancestry

	enum location: ["KL","JB","Penang","Melaka"]
  	enum position: ["REN","Team Leader","Team Manager"]

  	scope :approved, -> { where(approved?: true) }
  	scope :pending, -> { where(approved?: false) }

	def display_name
		prefered_name
	end

	def leader?
		pseudo_team.overriding
	end

	def pseudo_team_members
		user_ids = pseudo_team.subtree.pluck(:leader_id)
		User.where(id: user_ids)
	end

	def pseudo_team_sales
		pseudo_team_members.map(&:sales).flatten.uniq
	end


end
