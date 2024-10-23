# frozen_string_literal: true

class TodoList < ApplicationRecord
  has_many :todos, dependent: :destroy, inverse_of: :todo_list

  belongs_to :user, required: true, inverse_of: :todo_lists

  scope :default, -> { where(default: true) }
  scope :non_default, -> { where(default: false) }

  # Right now, using a 4 line lambda is okay, but I would consider extract a method and referencing it here
  scope :order_by, ->(params) {
    order = params[:order]&.strip&.downcase == 'asc' ? :asc : :desc

    sort_by = params[:sort_by]&.strip&.downcase

    column_name = column_names.excluding('id', 'user_id').include?(sort_by) ? sort_by : 'id'

    order(column_name => order)
  }

  validates :title, presence: true
  validates :default, inclusion: { in: [true, false] }
  validate :default_uniqueness

  # A typical pattern would be to make a new serializer class for serializing stored or received json <-> hash
  # not a strong recommendation, but something to consider
  def serialize_as_json
    as_json(except: [:user_id])
  end

  private

    def default_uniqueness
      errors.add(:default, 'already exists') if default? && user.todo_lists.default.exists?
    end
end
