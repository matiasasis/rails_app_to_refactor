# frozen_string_literal: true

# consider using Annotate gem, it can help with understanding what columns are available without booting the console
class User < ApplicationRecord
  has_many :todo_lists, dependent: :destroy, inverse_of: :user
  has_many :todos, through: :todo_lists

  has_one :default_todo_list, ->(user) { user.todo_lists.default }, class_name: 'TodoList'

  # Not for now, but if this list would get larger, it might be worth extracting these into a concern(s)
  # it would help with organization and readability
  validates :name, presence: true
  validates :email, presence: true, format: URI::MailTo::EMAIL_REGEXP, uniqueness: true
  # consider assigning 36 and 64 to named constants to make clear WHY those numbers are being used
  validates :token, presence: true, length: { is: 36 }, uniqueness: true
  # add validate with PasswordValidator
  validates :password_digest, presence: true, length: { is: 64 }

  after_create :create_default_todo_list
  after_commit :send_welcome_email, on: :create

  private

    def create_default_todo_list
      todo_lists.create!(title: 'Default', default: true)
    end

  # this seems fine for now, but if we are sending many more mailers then
  # consider extracting this UserMailer call into it's own class (e.g. MailerService)
    def send_welcome_email
      UserMailer.with(user: self).welcome.deliver_later
    end
end
