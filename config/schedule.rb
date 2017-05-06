# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

require_relative '../lib/bills_serializer'
require_relative '../lib/send_email'
require 'dotenv'
Dotenv.load('config/.env')
logger = Bills_Logger.new('Scheduler', 'log/scheduler.log', 'debug')
bills = Bills_Serializer.new('config/bills.yaml').get_bills

bills.each do |id, bill|
  root_dir=ENV['BILL_NOTIFIER_ROOT_DIR']
  to_email = ENV['BILLS_EMAIL']
  amount_currency=bill[:amount_currency]
  name=bill[:name]
  cron=bill[:cronjob]
  in_days=bill[:in_days]
  every cron do
     command "cd #{root_dir} && ruby lib/send_email.rb '#{to_email}' '#{name} bill is due soon!' 'You need to pay #{name} in the amount of #{amount_currency} in #{in_days} day(s).'"
    # command "echo 'You need to pay #{name} in the amount of #{amount_currency} in #{in_days} day(s).'"
  end
end