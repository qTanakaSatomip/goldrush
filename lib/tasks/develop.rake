namespace :dev do
  def logger
    RAILS_DEFAULT_LOGGER
  end
  
  desc "Put log task"
  task :putlog => :environment do
    logger.info "Start Put log batch: " + Time.now.strftime("%Y/%m/%d %H:%M:%S")

    logger.info "End Put log addresses batch: " + Time.now.strftime("%Y/%m/%d %H:%M:%S")
  end

end
