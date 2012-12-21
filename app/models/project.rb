class Project < ActiveRecord::Base
  include AutoTypeName
  has_many :personal_sales, :conditions => "personal_sales.deleted = 0"
  has_many :project_members, :conditions => "project_members.deleted = 0"
  belongs_to :business_partner, :conditions => "business_partners.deleted = 0"

  validates_presence_of :project_name, :project_short_name, :project_name_kana, :project_code_name, :pic_id, :project_start_date, :project_end_date, :project_type
  validates_uniqueness_of :project_code_name, :case_sensitive => false
  validates_uniqueness_of :project_name, :case_sensitive => false

  def members
    @members || (@members = User.find(:all, :include => [:project_members], :conditions => ["users.deleted = 0 and project_members.deleted = 0 and project_members.project_id = ?", id]))
  end

  def base_months
    @base_months || (@base_months = BaseMonth.find(:all, :conditions => ["deleted = 0 and (start_date <= ? and end_date >= ?)", project_end_date, project_start_date], :order => "start_date"))
  end

  def Project.get_active_projects
    find(:all, :conditions => "deleted = 0 and project_status_type = 'active'")
  end

end
