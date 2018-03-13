# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string
#  encrypted_password     :string
#  name                   :string
#  prefered_name          :string           not null
#  phone_no               :string
#  birthday               :date
#  team_id                :integer
#  ancestry               :string
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  admin                  :boolean          default(FALSE)
#  archived               :boolean          default(FALSE)
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  locked_at              :datetime
#  ic_no                  :string
#  location               :string
#
# Indexes
#
#  index_users_on_ancestry              (ancestry)
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_prefered_name         (prefered_name)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_team_id               (team_id)
#

class User < ApplicationRecord
	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable and :omniauthable
	devise :database_authenticatable, 
	       :recoverable, :rememberable, :trackable, :validatable, 
	       :registerable, :confirmable, :lockable

	extend Enumerize

    # belongs_to :team, optional: true
    has_one :leader, through: :team
    has_one :team, foreign_key: :leader_id
	has_many :salevalues, dependent: :destroy
	has_many :sales, ->{distinct}, through: :salevalues
	has_many :projects, ->{distinct}, through: :sales
	has_many :units, ->{distinct}, through: :sales
	has_many :positions, through: :team

	has_ancestry orphan_strategy: :adopt

	enumerize :location, in: ["KL","JB","Penang","Melaka"]

  	scope :approved, -> { where(locked_at: nil, archived: false) }
  	scope :pending, -> { where.not(locked_at: nil).where(unconfirmed_email: nil, archived: false) }
  	scope :upline_eq, -> (id){
  		if id.is_a? String
			id = id[/\d+/].to_i
		end
		user = User.find(id)
		teams = user.team.subtree
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
  	validates :parent_id, presence: true, unless: proc { is_root? || admin? }
  	validates :location, presence: true, unless: proc { admin? }

  	before_validation :titleize_name
  	before_validation :downcase_email
  	before_create :set_team
  	before_create :lock_user
  	after_create :create_team

	def display_name
		prefered_name
	end

	def self.ransackable_scopes(_auth_object = nil)
	  [:upline_eq, :referrer_eq]
	end

	def leader?
		positions.last.overriding
		# team.overriding
	end

	def team_members
		user_ids = team.subtree.pluck(:leader_id)
		User.where(id: user_ids)
	end

	def team_sales
		Sale.search(users_id_in: team_members.ids).result
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

	def create_team
		Team.create(leader_id: id, parent_id: parent.team.id)
	end

	def lock_user
		self.locked_at = Time.now
	end

end
