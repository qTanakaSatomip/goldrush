# -*- encoding: utf-8 -*-
module DateTimeUtil
  
  def DateTimeUtil.calHourMinuteFormat(sec)
    hour = (((sec) / 3600)).truncate
    min = (((sec) % 3600) / 60).truncate
    return "#{hour}:#{sprintf('%.2d', min.to_i)}"
  end
  
  def DateTimeUtil.calHourMinuteFormatJa(sec)
    hour = (((sec) / 3600)).truncate
    min = (((sec) % 3600) / 60).truncate
    return "#{hour}時間#{sprintf('%.2d', min.to_i)}分"
  end

  def DateTimeUtil.convert10MinutesUnit(sec)
    hour1, min1 = convert10Minutes(sec, 5) # 四捨五入
    return hour_min_to_sec(hour1, min1)
  end
  
  def DateTimeUtil.convert10MinutesUnitUp(sec)
    hour1, min1 = convert10Minutes(sec, 9) # 切りあげ
    return hour_min_to_sec(hour1, min1)
  end

  def DateTimeUtil.convert10MinutesUnitDown(sec)
    hour1, min1 = convert10Minutes(sec, 0) # 切り捨て
    return hour_min_to_sec(hour1, min1)
  end
  
  #
  # 10分以下の処理
  # plus=0:切り捨て, plus=5:四捨五入, plus=9:切り上げ
  def DateTimeUtil.convert10Minutes(sec, plus)
    hour, min = sec_to_hour_min(sec)
    x = (min + plus) / 10    # plusを足して切り捨て
    hour += (x / 6)          # 6(60)をoverしていたら繰り上げ
    min = x * 10 % 60        # 60overを0にカット
    return hour, min
  end

  def DateTimeUtil.sec_to_hour_min(sec)
    return (sec / (60 * 60)), (sec / 60 % 60)
  end

  def DateTimeUtil.hour_min_to_sec(hour, min)
    return (hour * 60 * 60) + (min * 60)
  end

  # "10:10" format to sec...
  def DateTimeUtil.hourminstr_to_sec(hourmin)
    arr = hourmin.split(":")
    return hour_min_to_sec(arr[0].to_i, arr[1].to_i)
  end

  def DateTimeUtil.str_to_date(str, &block)
    begin
      str.to_date
    rescue
      block_given? && block.call($!)
      nil
    end
  end

end
