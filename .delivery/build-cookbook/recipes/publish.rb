################################################################################
# Welcome to the publish phase
#
# This is run as the delivery build user, and defers to the
# `habitat-build` cookbook to create the artifact for the omnitruck
# application that will be deployed in later stages.
#
################################################################################

include_recipe 'chef-sugar::default'
include_recipe 'delivery-truck::publish'

# custom publish steps instead of using `habitat-build::publish`,
# because we're multipackage.

project_secrets = get_project_secrets
_origin = 'delivery'

if habitat_origin_key?
  keyname = project_secrets['habitat']['keyname']
  _origin = keyname.split('-')[0...-1].join('-')
end

%w{omnitruck omnitruck-unicorn-proxy}.each do |pkg|
  hab_build pkg do
    origin _origin
    plan_dir ::File.join(habitat_plan_dir, pkg)
    home_dir delivery_workspace
    cwd node['delivery']['workspace']['repo']
    auth_token project_secrets['habitat']['depot_token']
    depot_url node['habitat-build']['depot-url']
    only_if { habitat_depot_token? }
    action [:build, :publish, :save_application_release]
  end
end
