# -*- encoding: utf-8 -*-
class Type < ActiveRecord::Base

  validates_presence_of :long_name
  validates_numericality_of :display_order1, :only_integer => true
  
  
  
end
