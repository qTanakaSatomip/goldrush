class WorkingLog < ActiveRecord::Base
  include AutoTypeName
  belongs_to :daily_working
  belongs_to :user
  belongs_to :project

  def WorkingLog.set_working_log!(daily_working, str, login)
    str.each do |line|
      next if line.strip.blank? # 空行は無視
      working_time = nil
      working_kind = ""
      if /^\[(\d+)\]/ =~ line
        working_time = $1.to_i * 60 * 60
        working_kind = $'.strip
      elsif /^\[(\d+):(\d+)\]/ =~ line
        working_time = $1.to_i * 60 * 60
        working_time += $2.to_i * 60
        working_kind = $'.strip
      else
        raise ValidationAbort.new("ワークログの作業時間を入力してください") if working_kind.blank?
      end
      raise ValidationAbort.new("ワークログの作業内容を入力してください") if working_kind.blank?
      wlog = WorkingLog.new({:user_id => daily_working.user_id, :working_time => working_time, :working_kind => working_kind})
      wlog.daily_working = daily_working
      wlog.created_user = login
      wlog.updated_user = login
      wlog.save!
    end
  end
end
