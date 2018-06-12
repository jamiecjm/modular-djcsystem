ActiveAdmin.register_page "Dashboard" do

  menu false

  content title: proc{ I18n.t("active_admin.dashboard") } do
    columns do
        panel 'System Updates' do
          controller.instance_variable_get(:@response).each do |release|
            div class: 'timeline-object' do
              span release['created_at'].to_date
              span release['tag_name']
              h4 release['name']
              markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, extensions = {})
              div markdown.render(release['body']).html_safe
            end
          end
        end
    end
    columns do
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
            if current_user.admin?
                a href: new_project_path, class: 'card' do
                    span class: 'card-content' do
                        'New Project'
                    end
                end
                a href: projects_path, class: 'card' do
                    span class: 'card-content' do
                        'Project Lists'
                    end
                end
                a href: positions_path, class: 'card' do
                    span class: 'card-content' do
                        'Positions'
                    end
                end
                a href: company_profiles_path, class: 'card' do
                    span class: 'card-content' do
                        'Company Profile'
                    end
                end
            end
        end
    end
  end # content

  controller do

    def index
      url = 'https://api.github.com/repos/jamiecjm/modular-djcsystem/releases'
      response = RestClient.get url
      @response = JSON.parse(response.body)
    end

  end

end
