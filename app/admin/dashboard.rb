ActiveAdmin.register_page "Dashboard" do

  menu false

  content title: proc{ I18n.t("active_admin.dashboard") } do
    columns do
        column do
            panel 'Quick Links', id: 'quick-links' do
                a href: new_sale_path, class: 'card' do
                    span class: 'card-content' do
                        'New Sale'
                    end
                end
                a href: sales_path, class: 'card' do
                    span class: 'card-content' do
                        'Team Sales'
                    end
                end
                a href: salevalues_path, class: 'card' do
                    span class: 'card-content' do
                        'Individual Sales'
                    end
                end
                a href: teams_path, class: 'card' do
                    span class: 'card-content' do
                        'Team Performance'
                    end
                end
                a href: users_path, class: 'card' do
                    span class: 'card-content' do
                        'Team members'
                    end
                end
            end
        end

        column
    end
  end # content
end
