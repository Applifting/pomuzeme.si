ActiveAdmin.register_page 'Import Data' do
  menu false

  page_action :import_data, method: :post do
    temp_file = params[:import_form][:filename]
    group     = Group.find(params[:import_form][:group_id])

    DataImportService.call(temp_file.path, group)

    send_data File.read(DataImportService::ArrayToCsv::OUTPUT), filename: 'vysledek_importu.csv'
  end

  page_action :delete_data, method: :post do
    group = Group.find params[:delete_form][:group_id]

    redirect_to(admin_import_data_path, notice: 'Skupina nenalezena') && return unless group

    DataImportService.cleanup group

    redirect_to(admin_import_data_path, notice: 'Smazána data: dobrovolníci, štítky, poptávky')
  end

  content do
    managable_groups = current_user.cached_admin? ? Group.all : current_user.coordinating_groups

    tabs do
      tab 'Import' do
        panel '' do
          active_admin_form_for :import_form, url: admin_import_data_import_data_path do |f|
            f.inputs do
              f.input :group_id, as: :select,
                                 label: 'Import do skupiny',
                                 collection: managable_groups,
                                 include_blank: false
              f.input :filename, as: :file, label: 'Soubor (csv)'
            end
            f.actions
          end
        end
      end
      tab 'Smazání dat' do
        panel '' do
          active_admin_form_for :delete_form, url: admin_import_data_delete_data_path do |f|
            f.inputs do
              f.input :group_id, as: :select,
                                 label: 'Smazat data skupiny',
                                 collection: managable_groups,
                                 include_blank: false
            end
            f.actions
          end
        end
      end
    end
  end
end
