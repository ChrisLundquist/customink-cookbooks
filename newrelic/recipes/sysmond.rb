#
# Cookbook Name:: newrelic
# Recipe:: sysmond
#
# Copyright 2011, CustomInk, LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
include_recipe "newrelic::repo"

package "newrelic-sysmond"

execute "kill old new relic server agent" do
  # This is a clean-up task that will handle a newrelic-sysmond
  # with its pid file in a non-standard location
  command "kill `cat /var/run/nrsysmond.pid` && rm /var/run/nrsysmond.pid"
  action :nothing
  only_if do File.exist?("/var/run/nrsysmond.pid") end
end

directory "/var/run/newrelic" do
  recursive true
  owner "root"
  group "root"
  notifies :run, "execute[kill old new relic server agent]", :immediately
end

execute "configure newrelic-sysmond" do
  command "nrsysmond-config --set license_key=#{node[:newrelic][:license_key]}"
end

service "newrelic-sysmond" do
  supports [:start,:stop,:status,:restart]
  action   [:start,:enable]
end