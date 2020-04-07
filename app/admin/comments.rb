ActiveAdmin.register ActiveAdmin::Comment, as: 'Comment' do
  menu false

  actions :all, except: %i[index]

  controller do
    def destroy
      super do |success, failure|
        success.html { redirect_back fallback_location: request.referer }
        failure.html { redirect_back fallback_location: request.referer }
      end
    end
  end
end
