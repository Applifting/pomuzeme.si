ActiveAdmin.register_page 'Import Data' do
  menu false

  page_action :import_data, method: :post do
    temp_file = params[:import][:filename]
    group     = Group.find(params[:import][:group_id])

    DataImportService.call(temp_file.path, group)

    send_data File.read(DataImportService::ArrayToCsv::OUTPUT), filename: 'vysledek_importu.csv'
  end

  content do
    managable_groups = current_user.admin? ? Group.all : current_user.coordinating_groups

    active_admin_form_for :import, url: admin_import_data_import_data_path do |f|
      f.inputs 'Import' do
        f.input :group_id, as: :select,
                           collection: managable_groups,
                           include_blank: false
        f.input :filename, as: :file
      end
      f.actions
    end
  end
end
