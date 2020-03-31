namespace :messages do
  task receive: :environment do
    loop do
      response = SmsService.receive
      break if response.blank?
    end
  end
end
