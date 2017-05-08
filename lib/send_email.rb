#!/usr/bin/ruby

libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'gmail'
require 'dotenv'
Dotenv.load('config/.env')
require 'bills_serializer'

class Send_Email
  attr_accessor :to, :subject, :body
  def initialize
    @username = ENV['GMAIL_USERNAME']
    @password = ENV['GMAIL_PASSWORD']
  end

  def send
    yield self
    send_email(@to, @subject, @body)
  end

  def send_email(to, subject, body)
    Gmail.connect(@username, @password) do |gmail|
      email = gmail.compose do
        to to
        subject subject
        body body
      end
      email.deliver!
    end
  end
end

logger = BillsLogger.new('SEND_EMAIL', 'log/send_email.log', 'debug')
x = Send_Email.new
if ARGV[0]
  begin
    logger.log.info('Sending email to ' + ARGV[0])
    logger.log.debug("to=#{ARGV[0]}")
    logger.log.debug("subject=#{ARGV[1]}")
    logger.log.debug("body=#{ARGV[2]}")
    x.send do |email|
      email.to = ARGV[0]
      email.subject = ARGV[1]
      email.body = ARGV[2]
    end
  rescue => explosions
    logger.log.error('Failed to send email')
    logger.log.error(explosions)
  end
end
