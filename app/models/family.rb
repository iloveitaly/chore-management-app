class Family < ApplicationRecord
  has_many :accounts, -> { order(position: :asc) }
  has_many :parents, foreign_key: 'family_id', class_name: 'User'
  has_many :children, -> { order(created_at: :desc) }
  has_many :chores
end

class FamilySerializer < ActiveModel::Serializer
  attributes :id, :name, :parents

  def parents
    object.parents.map do |parent|
      {
        name: parent.name,
        email: parent.email,
        id: parent.id
      }
    end
  end
end
