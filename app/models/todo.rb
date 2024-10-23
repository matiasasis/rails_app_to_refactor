# frozen_string_literal: true

class Todo < ApplicationRecord
  attr_accessor :completed

  belongs_to :todo_list, required: true, inverse_of: :todos

  has_one :user, through: :todo_list

  scope :overdue, -> { incomplete.where('due_at <= ?', Time.current) }
  scope :completed, -> { where.not(completed_at: nil) }
  scope :incomplete, -> { where(completed_at: nil) }

  scope :filter_by_status, ->(params) {
    case params[:status]&.strip&.downcase
    when 'overdue' then overdue
    when 'completed' then completed
    when 'incomplete' then incomplete
    else all
    end
  }

  # Same thing, consider extracting this below, and referencing by :method_name
  scope :order_by, ->(params) {
    order = params[:order]&.strip&.downcase == 'asc' ? :asc : :desc

    sort_by = params[:sort_by]&.strip&.downcase

    column_name = column_names.excluding('id').include?(sort_by) ? sort_by : 'id'

    order(column_name => order)
  }

  # this is readable, but simple enough to be refactored into a ternary if needed (no else case)
  before_validation on: :update do
    case completed
    when 'true' then complete
    when 'false' then incomplete
    end
  end

  validates :title, presence: true
  validates :due_at, presence: true, allow_nil: true
  validates :completed_at, presence: true, allow_nil: true

  def overdue?
    return false if !due_at || completed_at

    due_at <= Time.current
  end

  # I believe this is a bit redundant, but worth chatting about
  def incomplete?
    completed_at.nil?
  end

  # consider using 1 method (completed), and updating uses to negate when appropriate
  def completed?
    !incomplete?
  end

  def status
    return 'completed' if completed?
    return 'overdue' if overdue?

    'incomplete'
  end

  # consider a single method when we are setting the completion state
  # These methods are repetitive (and covering inverses), we could for instance have a
  # .set_completion() method, which could or could not take a param (in the not case, making an assumption
  # that flipping the boolean would be okay) and set completed_at inline.
  def complete
    self.completed_at = Time.current unless completed?
  end

  def complete!
    complete

    self.save if completed_at_changed?
  end

  def incomplete
    self.completed_at = nil unless incomplete?
  end

  def incomplete!
    incomplete

    self.save if completed_at_changed?
  end

  def serialize_as_json
    as_json(except: [:completed], methods: :status)
  end
end
