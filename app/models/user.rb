class User < ApplicationRecord

	belongs_to :team
	has_many :salevalues, dependent: :destroy
	has_many :sales, through: :salevalues
	has_many :projects, through: :sales
	has_many :units, through: :sales

	has_ancestry

end
