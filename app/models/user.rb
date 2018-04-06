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
#  referrer_id            :integer
#  upline_id              :integer
#
# Indexes
#
#  index_users_on_ancestry              (ancestry)
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_prefered_name         (prefered_name)
#  index_users_on_referrer_id           (referrer_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_team_id               (team_id)
#  index_users_on_upline_id             (upline_id)
#

class User < ApplicationRecord
	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable and :omniauthable
	devise :database_authenticatable, 
	       :recoverable, :rememberable, :trackable, :validatable, 
	       :registerable, :confirmable, :lockable

	extend Enumerize

	has_many :teams, ->{order('teams.effective_date asc')}, dependent: :destroy
	has_many :positions, through: :teams
	has_one :current_team, ->{where('teams.effective_date <= ?', Date.today).reorder('teams.effective_date DESC')}, class_name: 'Team'
	has_one :current_position, through: :current_team, source: :position
	has_many :salevalues, through: :teams
	has_many :sales, ->{order(:date)}, through: :salevalues
	belongs_to :referrer, class_name: 'User', optional: true
	belongs_to :upline, class_name: 'Team', optional: true

	accepts_nested_attributes_for :teams

	has_ancestry orphan_strategy: :adopt

	enumerize :location, in: ["KL","JB","Penang","Melaka"]

  	scope :approved, -> { order(:prefered_name).where(locked_at: nil, archived: false) }
  	scope :pending, -> { where.not(locked_at: nil).where(unconfirmed_email: nil, archived: false) }
  	scope :upline_eq, -> (id){
  		if id.is_a? String
			id = id[/\d+/].to_i
		end
		user = User.find(id)
		search(id_in: user.current_team_members.pluck(:id)).result	
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
  	# validates :parent_id, presence: true, if: proc{ new_record? && !admin? }
  	validates :location, presence: true, unless: proc { admin? }

  	before_validation :titleize_name
  	before_validation :downcase_email, unless: proc {email.nil?}
  	before_save :set_referrer_id
  	before_create :lock_user, unless: proc {admin?}
  	after_create :set_team

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

	def current_team_members
		user_ids = current_team.subtree.current.pluck(:user_id).uniq
		User.where(id: user_ids)
	end

	def all_team_subtree
		teams.map(&:subtree).flatten
	end

	# def current_team_sales
	# 	Sale.search(users_id_in: team_members.ids).result
	# end

	def all_team_sales
		Sale.search(teams_id_in: all_team_subtree.pluck(:id)).result
	end

	def titleize_name
		self.name = name.upcase_first_word if name
		self.prefered_name = prefered_name.upcase_first_word if prefered_name
	end

	def downcase_email
		self.email = email.downcase
	end

	def set_team
		Team.create(user_id: id, parent_id: parent&.current_team&.id, position_id: Position.default.id, effective_date: '2000-1-1')
	end

	def lock_user
		self.locked_at = Time.now
	end

	def set_referrer_id
		self.referrer_id = ancestry&.split('/')&.last
	end

end
