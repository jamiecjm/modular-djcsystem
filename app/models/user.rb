class User < ApplicationRecord
	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable and :omniauthable
	devise :database_authenticatable, 
	       :recoverable, :rememberable, :trackable, :validatable, 
	       :registerable, :confirmable, :lockable

    belongs_to :team, optional: true
    has_one :leader, through: :team
    has_one :pseudo_team, class_name: 'Team', foreign_key: :leader_id
	has_many :salevalues, dependent: :destroy
	has_many :sales, ->{distinct}, through: :salevalues
	has_many :projects, ->{distinct}, through: :sales
	has_many :units, ->{distinct}, through: :sales

	has_ancestry orphan_strategy: :adopt

	enum location: ["KL","JB","Penang","Melaka"]
  	enum position: ["REN","Team Leader","Team Manager"]

  	scope :approved, -> { where(locked_at: nil, archived: false) }
  	scope :pending, -> { where.not(locked_at: nil).where(unconfirmed_email: nil, archived: false) }
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

  	validates :name, presence: true
  	validates :prefered_name, uniqueness: true
  	validates :prefered_name, presence: true
  	validates :email, presence: true
  	validates :parent_id, presence: true, unless: proc { is_root? }
  	validates :location, presence: true

  	before_validation :titleize_name
  	before_validation :downcase_email
  	before_create :set_team
  	before_create :lock_user
  	after_create :create_pseudo_team

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
		Sale.search(users_id: pseudo_team_members.ids).result
	end

	def titleize_name
		self.name = name.upcase_first_word if name
		self.prefered_name = prefered_name.upcase_first_word if prefered_name
	end

	def downcase_email
		self.email = email.downcase if email
	end

	def set_team
		self.team_id = parent.team_id
	end

	def create_pseudo_team
		Team.create(leader_id: id, parent_id: parent.pseudo_team.id)
	end

	def lock_user
		self.locked_at = Time.now
	end

end
