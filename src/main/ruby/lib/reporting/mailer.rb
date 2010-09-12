module Reporting
  class Mailer
    def initialize
      # lazy loading
      require 'net/smtp'
      require 'mailfactory'
      init_config UserConfig.instance.email
    end

    def notify_finish(subject, result, files)
      @receiver.each do |address|
        mail = MailFactory.new
        mail.from = @from
        mail.to = address
        mail.subject = "[simulation] " + subject
        mail.text = result
        files.each {|f| mail.attach f }

        send(mail, address)
      end
    end


    private
    def send(mail, toaddress)
      Net::SMTP.start(@server, @port, @domain, @username, @password, @auth_method) do |smtp|
        mail.to = toaddress
        smtp.send_message(mail.to_s(), @sender, toaddress)
      end
    end

    def init_config config
      @server = config['server'] || "localhost"
      @domain = config['domain'] || @server
      @username = config['username'] || 'root'
      @password = config['password'] || ''
      @sender = config['sender'] || "#@username@#@domain"
      @port = config['port'] || 25
      @auth_method = config['auth_method'] || :login
      @from = "\"Simulation Notifier\" <#@sender>"
      @receiver = config['receiver'] || []
    end
  end
end
