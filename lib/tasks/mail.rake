namespace :mail do
  
  def logger
    Rails.logger
  end

  desc "Parse and reply Mail. rake mail:recv_and_reply [DOMAIN='http://www.sharingss.net/coupe_xxx/']"
  task :parse_and_reply => :environment do
    logger.info "Start Recv and reply Mail.: " + Time.now.strftime("%Y/%m/%d %H:%M:%S")

#    if ENV['DOMAIN'].blank?
#      raise ValidationAbort.new("Invarid paramaters. DOMAIN=http://...")
#    end

    domain_name = ENV['DOMAIN'] || Configuration.get_value("system", "domain")

    # 標準入力を読み取って自動返信処理を呼び出す
    CoupeMailer.parse_and_reply(STDIN.read, domain_name)

    logger.info "Bye Parse and reply Mail.: " + Time.now.strftime("%Y/%m/%d %H:%M:%S")
  end

  desc "Recv and reply Mail. rake mail:recv_and_reply [DOMAIN='http://www.sharingss.net/coupe_xxx/']"
  task :recv_and_reply => :environment do
    logger.info "Start Recv and reply Mail.: " + Time.now.strftime("%Y/%m/%d %H:%M:%S")

#    if ENV['DOMAIN'].blank?
#      raise ValidationAbort.new("Invarid paramaters. DOMAIN=http://...")
#    end

    domain_name = ENV['DOMAIN'] || Configuration.get_value("system", "domain")

    # メールの受信／自動返信処理を呼び出す
    CoupeMailer.recv_and_reply(domain_name)

    logger.info "Bye Recv and reply Mail.: " + Time.now.strftime("%Y/%m/%d %H:%M:%S")
  end

  desc "Recv and reply Mail LOOP. rake mail:recv_and_reply [DOMAIN='http://www.sharingss.net/coupe_xxx/']"
  task :recv_and_reply_loop => :environment do
    logger.info "Start Recv and reply Mail LOOP.: " + Time.now.strftime("%Y/%m/%d %H:%M:%S")

#    if ENV['DOMAIN'].blank?
#      raise ValidationAbort.new("Invarid paramaters. DOMAIN=http://...")
#    end

    domain_name = ENV['DOMAIN'] || Configuration.get_value("system", "domain")

    interval = 10
    loop_count = 100
    ctrl_filename = File.join([RAILS_ROOT,'config','ctrl.yml'])
    exit_filename = File.join([RAILS_ROOT,'config','exit.dmy'])
    logger.debug "Try load '#{ctrl_filename}' file"
    if File.file? ctrl_filename
      File.open(ctrl_filename, 'r') do |file|
        doc = YAML.load file
        interval = doc["interval"] if doc["interval"]
        loop_count = doc["loop_count"] if doc["loop_count"]
        logger.debug "interval: #{interval}, loop_count: #{loop_count}"
      end
    end
    logger.info "Start while...(if u want exit to create #{exit_filename})"
    exit_flg = false
    while !exit_flg
      logger.debug "while ... " + Time.now.strftime("%Y/%m/%d %H:%M:%S")

      # メールの受信／自動返信処理を呼び出す
      CoupeMailer.recv_and_reply(domain_name)

      logger.debug "sleep #{interval} sec"
      sleep(interval)
      loop_count -= 1
      exit_flg = (loop_count == 0) || (File.file? exit_filename)
    end
    logger.info "Bye Recv and reply Mail LOOP.: " + Time.now.strftime("%Y/%m/%d %H:%M:%S")
  end

end
