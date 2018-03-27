# == Schema Information
#
# Table name: teams
#
#  id             :integer          not null, primary key
#  name           :string
#  user_id        :integer
#  ancestry       :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  effective_date :date
#  position_id    :integer
#  upline_id      :integer
#  hidden         :boolean          default(TRUE)
#  current        :boolean          default(TRUE)
#
# Indexes
#
#  index_teams_on_ancestry   (ancestry)
#  index_teams_on_upline_id  (upline_id)
#  index_teams_on_user_id    (user_id)
#

require 'rails_helper'

RSpec.describe Team, type: :model do
	before do
		root = FactoryBot.create(:root)
		children1 = FactoryBot.build(:children1)
		children1.parent = root
		children1.save
		children2 = FactoryBot.build(:children2)
		children2.parent = root
		children2.save
		grandchildren1 = FactoryBot.build(:grandchildren1)
		grandchildren1.parent = children1
		grandchildren1.save
		grandchildren2 = FactoryBot.build(:grandchildren2)
		grandchildren2.parent = children1
		grandchildren2.save
		grandchildren3 = FactoryBot.build(:grandchildren3)
		grandchildren3.parent = children2
		grandchildren3.save
		grandchildren4 = FactoryBot.build(:grandchildren4)
		grandchildren4.parent = children2
		grandchildren4.save
		t = Team.third.dup
		t.effective_date = Date.current + 1.month
		t.hidden = false
		t.save
	end

	context 'on create' do
		it 'automatically sets upline_id' do
			expect(Team.second.upline_id).to eq(Team.first.id)
		end
	end

	context 'on destroy' do
		it 'does not destroy the record' do
			t = Team.last
			t.destroy
			expect(t.destroyed?).to be_falsy
		end

		it 'adapt previous time point settings' do
			team = User.third.teams.last
			team.destroy
			last_attributes = team.attributes.except('id', 'effective_date', 'hidden', 'created_at', 'updated_at')
			previous_attributes = User.third.teams.first.attributes.except('id', 'effective_date', 'hidden', 'created_at', 'updated_at')
			expect(last_attributes).to eq(previous_attributes)
		end

		it 'hides the record' do
			t = Team.last
			t.destroy
			expect(t.hidden).to be_truthy
		end
	end

	# context 'on force destroy' do
	# 	it 'destroy the record' do
	# 		t = Team.last.dup
	# 		t.parent_id = nil
	# 		expect(t.save).to be_falsy
	# 	end
	# end

	context 'user creates another team' do

		it 'connects to the original ancestry tree' do
			expect(User.third.teams.last.parent_id).to eq(Team.first.id)
		end
		it 'creates a new ancestry tree' do
			expect(Team.count).to eq(10)
		end
	end


	context 'effective_date changed' do

		it 'updates all hidden subtree effective_date' do
			team = User.third.teams.last
			expect(team.subtree.pluck(:effective_date).uniq.first).to eq(team.effective_date)
		end	

		it 'does not update visible subtree' do
			team = User.third.teams.last
			children = team.children.first
			children.update(hidden: false)
			team.update(effective_date: Date.current + 5.days)
			expect(children.effective_date).not_to eq(Date.current + 5.days)
		end
	end

	context 'effective_date changed to an existed time point in the past' do
		before do
			t = Team.third.dup
			t.effective_date = Date.current + 2.months
			t.hidden = false
			t.save
			@total_team = Team.count
			
		end

		it 'update the existed time point' do
			User.third.teams.last.update(effective_date: Date.current, upline_id: nil)
			expect(Team.third.parent_id).to eq(nil)
		end

		it 'does not create new ancestry tree' do
			User.third.teams.last.update(effective_date: Date.current, upline_id: nil)
			expect(Team.count).to eq(@total_team)
		end

		it 'original timepoint adapt previous timepoint settings (1 timepoint in between)' do
			User.third.teams.last.update(effective_date: Date.current, upline_id: nil)
			last_attributes = User.third.teams.last.attributes.except('id', 'effective_date', 'hidden', 'created_at', 'updated_at')
			previous_attributes = User.third.teams.second.attributes.except('id', 'effective_date', 'hidden', 'created_at', 'updated_at')
			expect(last_attributes).to eq(previous_attributes)
		end

		it 'original timepoint adapt previous timepoint settings (no timepoint in between)' do
			User.third.teams.last.update(effective_date: Date.current+1.month, upline_id: nil)
			last_attributes = User.third.teams.last.attributes.except('id', 'effective_date', 'hidden', 'created_at', 'updated_at')
			previous_attributes = User.third.teams.second.attributes.except('id', 'effective_date', 'hidden', 'created_at', 'updated_at')
			expect(last_attributes).to eq(previous_attributes)
		end
	end

	context 'effective_date changed to an existed time point in the future' do
		before do
			t = Team.third.dup
			t.effective_date = Date.current + 2.months
			t.hidden = false
			t.save
			@total_team = Team.count
			User.third.teams.second.update(effective_date: Date.current + 2.months, upline_id: nil)
		end

		it 'update the existed time point' do
			expect(User.third.teams.last.parent_id).to eq(nil)
		end

		it 'does not create new ancestry tree' do
			expect(Team.count).to eq(@total_team)
		end

		it 'original timepoint adapt previous timepoint settings (1 timepoint in between)' do
			last_attributes = User.third.teams.second.attributes.except('id', 'effective_date', 'hidden', 'created_at', 'updated_at')
			previous_attributes = User.third.teams.first.attributes.except('id', 'effective_date', 'hidden', 'created_at', 'updated_at')
			expect(last_attributes).to eq(previous_attributes)
		end
	end

	context 'ancestry changed' do
		it 'does not create a new ancestry tree' do
			total_team = Team.count
			Team.third.update(parent_id: nil)
			expect(Team.count).to eq(total_team)
		end
	end

	context 'position_id changed' do
		it 'does not create a new ancestry tree' do
			total_team = Team.count
			Team.third.update(position_id: nil)
			expect(Team.count).to eq(total_team)
		end
	end
end
