require 'yaml'
require 'logging'

class Bills_Logger
  attr_reader :log
  def initialize(log_name, log_file, log_level)
    @log = Logging.logger[log_name]
    @log.add_appenders Logging.appenders.stdout, Logging.appenders.file(log_file)
    @log.level=Logging::LEVELS[log_level]
  end
end

class Bills_Serializer
  attr_reader(:date_format, :bills_yaml, :time_of_reminder, :currency)
  def initialize(bills_yaml_file)
    @logger = Bills_Logger.new('Bills_Serializer', 'log/Bills_Serializer.log', 'debug')
    yaml_file = File.open(bills_yaml_file, 'r')
    @bills_yaml = YAML.load(yaml_file)
    @date_format= date_serialization(@bills_yaml['config']['date_format'])
    @time_of_reminder = time_serialization(@bills_yaml['config']['time_of_reminder'])
    @num_days_before_reminder = @bills_yaml['config']['num_days_before_reminder']
    @currency = @bills_yaml['config']['currency']
  end
  def amount_with_currency(amount)
    @currency + amount.to_s
  end

  def get_bills
    bills = {}
    @bills_yaml['bills'].each do |id, bill|
      start_date=bill['start_date']
      frequency=bill['frequency'].downcase
      hour=time_of_reminder[:hour]
      minute=time_of_reminder[:minute]
      date = Date.strptime(start_date, @date_format)-@num_days_before_reminder
      day=date.day
      day_of_week = date.wday
      amount = bill['amount']
      amount_currency = amount_with_currency(amount)
      name = bill['name']
      description = bill['description']
      cronjob = bill_to_cron_serialization(frequency, hour, minute, day, day_of_week)
      bills.store(id, {:start_date => start_date, :frequency => frequency,
                       :amount_currency => amount_currency, :amount => amount,
                       :name => name, :description => description, :cronjob => cronjob,
                       :in_days => @num_days_before_reminder})
    end
    bills
  end

  def bill_to_cron_serialization(frequency, hour, minute, day, day_of_week)
      if frequency == 'monthly'
       "#{minute} #{hour} #{day} * *"
      elsif frequency == 'weekly'
        "#{minute} #{hour} * * #{day_of_week}"
      end
  end

  def time_serialization(time)
    hour = time / 3600
    minute = time % 3600 / 60
    if hour < 24 and minute < 60
      {:hour => hour, :minute => minute}
    else
      @logger.log.error("Invalid time provided")
      nil
    end

  end

  def date_serialization(date_format)
    formated_date=date_format.split("").map do |e|
      e=e.downcase
      e=='d' || e=='m' ? "%#{e}" : "%#{e.upcase}"
    end
  formated_date.join("-")
  end
end

