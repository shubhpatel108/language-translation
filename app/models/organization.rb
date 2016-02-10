# == Schema Information
#
# Table name: organizations
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Organization < ActiveRecord::Base
  has_many :users
  has_many :countries

  validates_presence_of :name
  validates_uniqueness_of :name, case_sensitive: false
end
