#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Actions
  module Staypuft
    module Host
      class Deploy < Actions::Base

        def plan(host)
          Type! host, ::Host::Base

          input.update host: { id: host.id, name: host.name }

          sequence do
            plan_action Host::Build, host.id
            plan_action Host::WaitUntilInstalled, host.id
            # TODO: wait until host is restarted after provisioning (wait for report)
          end
        end

        def humanized_output
          # TODO: fix dynflow to allow better progress getting
          steps    = planned_actions.inject([]) { |s, a| s + a.steps[1..2] }.compact
          progress = steps.map(&:progress).map(&:first).reduce(&:+) / steps.size
          format '%3d%% %s', progress * 100, input[:host][:name]
        end

      end
    end
  end
end
