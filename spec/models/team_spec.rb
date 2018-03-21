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
#  hidden         :boolean          default(FALSE)
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
			t = Team.third.dup
			t.parent_id = nil
			t.effective_date = Date.current + 1.month
			t.save
			team = User.third.teams.last
			team.destroy
			expect(team.parent_id).to eq(User.first.teams.second.id)
		end

		it 'hides the record' do
			t = Team.last
			t.destroy
			expect(t.hidden).to be_truthy
		end
	end

	context 'on force destroy' do
		it 'destroy the record' do
			t = Team.last.dup
			t.parent_id = nil
			expect(t.save).to be_falsy
		end
	end

	context 'user creates another team' do
		it 'creates a new ancestry tree' do
			total_team = Team.count
			t = Team.first.dup
			t.effective_date = Date.current + 1.month
			t.save
			expect(Team.count).to eq(total_team*2)
		end
	end

	context 'effective_date changed to future' do
		it 'hides the record' do
			total_team = Team.count
			t = Team.third.dup
			t.parent_id = nil
			t.effective_date = Date.current + 1.month
			t.save
			t.update(effective_date: Date.current + 2.month)
			team = User.third.teams.second
			expect(team.hidden).to be_truthy
		end

		it 'does not create a new ancestry tree if there is no previous_team' do
			total_team = Team.count
			Team.first.update(effective_date: 1.month.ago)
			expect(Team.count).to eq(total_team)
		end

		it 'creates a new ancestry tree if there is a previous_team' do
			total_team = Team.count
			t = Team.third.dup
			t.parent_id = nil
			t.effective_date = Date.current + 1.month
			t.save
			t.update(effective_date: Date.current + 2.month)
			expect(Team.count).to eq(total_team*3)
		end

		it 'revert current team changes if there is a previous_team' do
			total_team = Team.count
			t = Team.third.dup
			t.parent_id = nil
			t.effective_date = Date.current + 1.month
			t.save
			id1 = t.id
			t.update(effective_date: Date.current + 2.month)
			expect(Team.find(id1).root?).to be_falsy
		end

		it 'remain other team changes if there is a previous_team' do
			total_team = Team.count
			t = Team.third.dup
			t.parent_id = nil
			t.effective_date = Date.current + 1.month
			t.save
			id2 = Team.last.id
			Team.last.update(parent_id: nil)
			t.update(effective_date: Date.current + 2.month)
			expect(Team.find(id2).parent_id).to eq(nil)
		end
	end

	context 'effective_date changed to the past with another time point in between' do
		before do
			t = Team.third.dup
			t.parent_id = nil
			t.effective_date = Date.current + 1.month
			t.save
			Team.last.update(parent_id: nil, effective_date: Date.current + 2.month)
			User.last.teams.last.update(effective_date: Date.current + 5.days)
		end

		it 'revert other team changes if there is a previous_team' do
			team = User.third.teams.find_by(effective_date:  Date.current + 5.days)
			parent = User.first.teams.find_by(effective_date:  Date.current + 5.days)
			expect(team.parent_id).to eq(parent.id)
		end

		it 'remain current team changes if there is a previous_team' do
			team = User.last.teams.find_by(effective_date:  Date.current + 5.days)
			expect(team.parent_id).to eq(nil)
		end

		it 'revert original time point to be inline with previous time point changes' do
			team = User.last.teams.find_by(effective_date: Date.current + 2.month)
			parent = User.third.teams.find_by(effective_date:  Date.current + 2.month)
			expect(team.parent_id).to eq(parent.id)
		end
	end

	context 'effective_date changed to the past without changes in between' do
		before do
			t = Team.third.dup
			t.parent_id = nil
			t.effective_date = Date.current + 1.month
			t.save
			Team.last.update(parent_id: nil, effective_date: Date.current + 2.month)
			User.last.teams.last.update(effective_date: Date.current + 1.month + 5.days)
		end

		it 'remain all original changes' do
			team = User.last.teams.find_by(effective_date: Date.current + 1.month + 5.days)
			expect(team.parent_id).to eq(nil)
		end

		it 'original time point has current changes' do
			team = User.last.teams.find_by(effective_date: Date.current + 2.month)
			expect(team.parent_id).to eq(nil)
		end
	end

	context 'effective_date changed to first time point' do
		it 'does not create ancestry tree' do
			t = Team.third.dup
			t.parent_id = nil
			t.effective_date = Date.current + 1.month
			t.save
			User.third.teams.second.update(effective_date: Date.current - 1.month)
			expect(Team.where(effective_date: Date.current - 1.month).length).to eq(1)
		end
	end

	context 'effective_date changed to an existed time point' do
		before do
			t = Team.third.dup
			t.parent_id = nil
			t.effective_date = Date.current + 1.month
			t.save
			@total_team = Team.count
			t.update(effective_date: Date.current, parent_id: nil)
		end

		it 'update the existed time point' do
			expect(Team.third.parent_id).to eq(nil)
		end

		it 'does not create new ancestry tree' do
			expect(Team.count).to eq(@total_team)
		end
	end

	# context 'after ancestry tree is built' do
	# 	it 'resets skip_build_root' do
	# 		t = Team.first.dup
	# 		t.effective_date = Date.current + 1.month
	# 		t.save
	# 		expect(t.skip_build_root).to eq(nil)
	# 	end
	# 	it 'resets skip_create_new_time point' do
	# 		t = Team.first.dup
	# 		t.effective_date = Date.current + 1.month
	# 		t.save
	# 		expect(t.skip_create_new_timepoint).to eq(nil)
	# 	end
	# end

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
