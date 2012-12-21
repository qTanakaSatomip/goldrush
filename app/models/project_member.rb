# -*- encoding: utf-8 -*-
class ProjectMember < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
end
