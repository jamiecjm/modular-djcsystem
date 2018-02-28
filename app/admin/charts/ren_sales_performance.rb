ActiveAdmin.register_page "REN Sales Performance" do

menu parent: 'Charts'

content title: 'REN Sales Performance' do
    columns do
        column span: 4.9, id: 'chart_div' do
            bar_chart controller.instance_variable_get(:@sales)
        end
        # render 'admin/charts/ren_sales_performance', sales: controller.instance_variable_get(:@sales)

        column do
            panel 'Filters', class: 'sidebar_section' do
              form action: 'team_sales_figure', 'data-remote': true, class: 'filter_form' do |f|

                div class: 'filter_form_field filter_date_range' do
                  label 'Date', class: 'label'
                  input type: :text, name: 'q[sales_date_gteq_datetime]', value: params['q']['sales_date_gteq_datetime'], class: 'datepicker', placeholder: 'From'
                  input type: :text, name: 'q[sales_date_lteq_datetime]', value: params['q']['sales_date_lteq_datetime'], class: 'datepicker', placeholder: 'To'
                end

                div class: 'filter_form_field' do
                  label 'Status', class: 'label'
                  
                  select name: 'q[sales_status_eq]' do
                    option
                    Sale.statuses.each do |k,v|
                      option value: v do
                        k
                      end
                    end
                  end
                end

                div class: 'filter_form_field' do
                  label 'Location', class: 'label'
                  
                  select name: 'q[users_location_eq]' do
                    option
                    User.locations.each do |k,v|
                      option value: v do
                        k
                      end
                    end
                  end
                end

                div class: 'filter_form_field' do
                  label 'Upline', class: 'label'
                  
                  select name: 'q[upline_eq]' do
                    option
                    User.order(:prefered_name).each do |u|
                      option value: "[#{u.id}]" do
                        u.prefered_name
                      end
                    end
                  end
                end
                
                input type: :submit
              end
            end
        end
    end
end

controller do
    def index
        if params['q'].blank?
            params['q'] = {}
        end
        if params['q']['sales_date_gteq_datetime'].blank?
            params['q']['sales_date_gteq_datetime'] = Date.current.beginning_of_month
        end
        if params['q']['sales_date_lteq_datetime'].blank?
            params['q']['sales_date_lteq_datetime'] = Date.today
        end
        if params['order'].blank?
            params['order'] = 'total_nett_value_desc'
        end
        if params['q']['sales_status_eq'].blank?
            params['q']['sales_status_in'] = [0,1]
        else
            params['q']['sales_status_in'] = nil
        end
        if params['q']['upline_eq'].blank?
            params['q']['upline_eq'] = "[#{current_user.id}]"
        end
        @sales = Team.search(params['q']).result.group('users.prefered_name').order('SUM(salevalues.nett_value) DESC').sum('salevalues.nett_value')
        @sales.map{|k,v| [k,v,v]}
    end
end

end
