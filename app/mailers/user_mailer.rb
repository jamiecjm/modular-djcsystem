class UserMailer < ApplicationMailer

  def approve_registration(user,website)
    @user     = user
    @company_name = website.superteam_name
    subject = "DJC Sales System: Approval Needed for Account Registration"
    recipients = [@user.leader,@user.team.root.leader]
    mail( :to      => recipients.map(&:email).uniq,
          :subject => subject) do |format|
            format.html
	  end
	end

  def notify(users,website)
    @users = users
    @company_name = website.superteam_name
    subject = "DJC Sales System: Account Registration Approved"
    mail( :to      => @users.pluck(:email),
          :subject => subject) do |format|
            format.html
    end
  end

	def generate_report(sale, website)
	    @sale = sale
      @company_name = website.superteam_name
	    mail( :to      => sale.users.pluck(:email),
	          :subject => "Sale Report \##{@sale.id}") do |format|
	            format.html
		end
	end

  def email_admin(var={})
    @user = var[:user]
    @sale = var[:sale]
    @company_name = var[:company].superteam_name
    @content = var[:content]
    mail( :to      => var[:to],
          :from   => @user.email,
          :reply_to => @user.email,
          :subject => var[:subject]) do |format|
            format.html
    end
  end


end
