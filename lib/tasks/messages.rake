namespace :messages do
  task receive: :environment do
    def receive
      response = SmsService.receive
      receive if response
    end
  end
end
