ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content title: proc { I18n.t('active_admin.dashboard') } do
    columns do
      column do
        panel 'Nábor' do
          count = GroupVolunteer.in_progress.in_recruitment_with_organisations(current_user.coordinating_organisations.select(:id)).count
          para 'dobrovolníci v aktivním náboru', class: :small
          a href: admin_recruitments_path do
            h3 count
          end
        end
      end

      column do
        panel 'Poptávky' do
          count = Request.not_closed
                         .with_organisations(current_user.coordinating_organisations.pluck(:id))
                         .without_coordinator
                         .count
          para 'bez koordinátora', class: :small
          a href: admin_organisation_requests_path do
            h3 count
          end
        end
      end
    end
  end
end
