ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content title: proc { I18n.t('active_admin.dashboard') } do
    div style: 'max-width: 600px' do
      columns do
        column do
          panel 'Nábor' do
            count = GroupVolunteer.in_progress.in_recruitment_with_organisations(current_user.coordinating_organisations.select(:id)).count

            a href: admin_recruitments_path do
              para 'dobrovolníci v náboru', class: :small
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

            a href: admin_organisation_requests_path do
              para 'bez koordinátora', class: :small
              h3 count
            end
          end
        end
      end
      hr
      columns do
        column do
          panel '', class: 'support' do
            h4 'Podpora'
            para 'Kontakt na podporu: 724 58 77 58, nebo 722 643 643.', class: :small
            mail_to = link_to 'info@pomuzeme.si', 'mailto:info@pomuzeme.si', target: '_blank'
            para "Potřebujete nahrát vaše stávající dobrovolníky? Napište na #{mail_to}".html_safe, class: :small
          end
        end
      end
    end
  end
end
