# == Schema Information
#
# Table name: languages
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime
#  updated_at :datetime
#

class Language < ActiveRecord::Base
  has_many :articles, dependent: :destroy

  validates_presence_of :name
  validates_uniqueness_of :name, case_sensitive: false
end
