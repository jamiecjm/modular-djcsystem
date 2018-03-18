# == Schema Information
#
# Table name: positions
#
#  id         :integer          not null, primary key
#  title      :string
#  overriding :boolean          default(FALSE)
#  ancestry   :string
#  default    :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_positions_on_ancestry  (ancestry)
#

FactoryBot.define do
  factory :default_position, class: 'Position' do
    title 'REN'
    default true
  end
end
