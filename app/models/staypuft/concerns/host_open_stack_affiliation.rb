module Staypuft
  module Concerns
    module HostOpenStackAffiliation
      extend ActiveSupport::Concern

      included do
        scope(:in_deployment, lambda do |deployment|
          joins(hostgroup: :deployment_role_hostgroup).
              where(DeploymentRoleHostgroup.table_name => { deployment_id: deployment })
        end)

        scope(:in_roles, lambda do |*roles|
          joins(hostgroup: :deployment_role_hostgroup).
              where(DeploymentRoleHostgroup.table_name => { role_id: roles })
        end)

        scope :in_role, lambda { |role| in_roles(role) }

        has_one :deployment, through: :hostgroup
      end


      def open_stack_deployed?
        !deployment.nil? && !deployment.in_progress? &&
        open_stack_environment_set? && open_stack_assigned?
      end

      def open_stack_environment_set?
        open_stack_assigned? &&
        respond_to?(:environment) &&
        environment != Environment.get_discovery
      end

      def open_stack_assigned?
        respond_to?(:hostgroup) &&
            hostgroup.try(:parent).try(:parent) == Hostgroup.get_base_hostgroup
      end

      def open_stack_unassign
        self.hostgroup = nil
        save!
      end
    end
  end
end

class ::Host::Managed::Jail < Safemode::Jail
  allow :deployment
end
