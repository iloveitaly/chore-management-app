class Chore < ApplicationRecord
  belongs_to :parent, class_name: 'User'
  belongs_to :family
  belongs_to :child

  validates :name, presence: true

  scope :incomplete, -> { where("status != 'paid'") }

  default_scope { where(deleted_at: nil) }
end

class ChoreSerializer < ActiveModel::Serializer
  attributes :id, :name, :due_date, :description, :value, :child_id, :parent_id,
             :paid_on, :child_name, :status, :recurring

  def child_name
    object.child.try(:name)
  end
end
