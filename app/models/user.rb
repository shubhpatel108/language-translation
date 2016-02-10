# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default("")
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  created_at             :datetime
#  updated_at             :datetime
#  first_name             :string
#  last_name              :string
#  username               :string
#  location               :string
#  contact                :string
#  gender                 :string
#  lang                   :string
#  tsv_data               :tsvector
#  invitation_token       :string
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_id          :integer
#  invited_by_type        :string
#  invitations_count      :integer          default(0)
#  authentication_token   :string
#  login_approval_at      :datetime
#  organization_id        :integer
#

class User < ActiveRecord::Base
  attr_accessor :no_invitation

  GENGER={male: "Male", female: "Female"}

  rolify
  include PgSearch

  belongs_to :organization

  # DEVISE: Include devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :validatable,
         :recoverable, :rememberable, :trackable, :token_authenticatable, :invitable

  default_scope -> { order('created_at DESC') }

  validates_uniqueness_of :username, case_sensitive: false

  validates_presence_of :username, :first_name, :last_name, :organization_id

  # default order when calling the User model
  default_scope -> { order('created_at DESC') }

  after_create  :send_invitation
  before_save   :ensure_authentication_token

  # PgSearch
  pg_search_scope :user_search,
    against: :tsv_data,
    using: {
        tsearch: {
            dictionary: 'english',
            any_word: true,
            prefix: true,
            tsvector_column: 'tsv_data'
        }
    }

  private
  def send_invitation
    invite! if no_invitation=="0"
  end
end
