class AnnualVacation < ActiveRecord::Base

  def remain_total
    self.day_total - self.used_total
  end

  def life_plan_remain_total
    self.life_plan_day_total - self.life_plan_used_total
  end

end
