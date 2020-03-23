# frozen_string_literal: true

module Ransackers
  module VolunteerRansacker
    extend ActiveSupport::Concern

    included do
      def self.rans_full_name
        first_name = Arel::Nodes::InfixOperation.new('||', arel_table[:first_name], Arel::Nodes.build_quoted(' '))
        Arel::Nodes::InfixOperation.new('||', first_name, arel_table[:last_name])
      end

      ransacker :email, formatter: proc { |query| query.strip } do |parent|
        parent.table[:email]
      end

      ransacker :full_name, formatter: proc { |query| query.strip } do |_parent|
        rans_full_name
      end
    end
  end
end
