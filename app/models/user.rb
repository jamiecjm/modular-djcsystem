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

  	default_scope { where(approved?: true) }
  	scope :pending, -> { unscoped.where(approved?: false).where.not(team_id: nil) }
  	scope :upline_eq, -> (id){
  		if id.is_a? String
			id = id[/\d+/].to_i
		end
		user = User.find(id)
		teams = user.pseudo_team.subtree
		users = teams.pluck(:leader_id)
		search(id_in: users).result	
  	}
  	scope :referrer_eq, -> (id){
  		if id.is_a? String
			id = id[/\d+/].to_i
		end
		user = User.find(id)
		search(id_in: user.children.ids).result 		
  	}

	def display_name
		prefered_name
	end

	def self.ransackable_scopes(_auth_object = nil)
	  [:upline_eq, :referrer_eq]
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
