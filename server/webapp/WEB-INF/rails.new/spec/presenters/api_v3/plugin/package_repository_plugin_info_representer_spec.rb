##########################################################################
# Copyright 2017 ThoughtWorks, Inc.
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
##########################################################################

require 'spec_helper'

describe ApiV3::Plugin::PackageRepositoryPluginInfoRepresenter do
  it 'should describe a package repository plugin plugin' do
    vendor = GoPluginDescriptor::Vendor.new('bob', 'https://bob.example.com')
    about = GoPluginDescriptor::About.new('Foo plugin', '1.2.3', '17.2.0', 'Does foo', vendor, ['Linux'])
    descriptor = GoPluginDescriptor.new('foo.example', '1.0', about, nil, nil, false)

    package_view = com.thoughtworks.go.server.ui.plugins.PluginView.new('package_view_template')
    package_settings = PluggableInstanceSettings.new([com.thoughtworks.go.server.ui.plugins.PluginConfiguration.new('url', {required: true, secure: false, display_name: 'Url', display_order: '1'}, nil)], package_view)

    repo_view = com.thoughtworks.go.server.ui.plugins.PluginView.new('role_config_view_template')
    repo_settings = PluggableInstanceSettings.new([com.thoughtworks.go.server.ui.plugins.PluginConfiguration.new('memberOf', {required: true, secure: false, display_name: 'Member Of', display_order: '1'}, nil)], repo_view)

    plugin_info = com.thoughtworks.go.server.ui.plugins.PackageRepositoryPluginInfo.new(descriptor, package_settings, repo_settings)
    actual_json = ApiV3::Plugin::PackageRepositoryPluginInfoRepresenter.new(plugin_info).to_hash(url_builder: UrlBuilder.new)

    expect(actual_json).to have_links(:self, :doc, :find)
    expect(actual_json).to have_link(:self).with_url('http://test.host/api/admin/plugin_info/foo.example')
    expect(actual_json).to have_link(:doc).with_url('https://api.gocd.io/#plugin-info')
    expect(actual_json).to have_link(:find).with_url('http://test.host/api/admin/plugin_info/:plugin_id')
    actual_json.delete(:_links)

    expect(actual_json).to eq({
                                id: 'foo.example',
                                version: '1.0',
                                type: 'package-repository',
                                about: {
                                  name: 'Foo plugin',
                                  version: '1.2.3',
                                  target_go_version: '17.2.0',
                                  description: 'Does foo',
                                  target_operating_systems: ['Linux'],
                                  vendor: {
                                    name: 'bob',
                                    url: 'https://bob.example.com'}
                                },
                                package_settings: ApiV3::Plugin::PluggableInstanceSettingsRepresenter.new(package_settings).to_hash(url_builder: UrlBuilder.new),
                                repository_settings: ApiV3::Plugin::PluggableInstanceSettingsRepresenter.new(repo_settings).to_hash(url_builder: UrlBuilder.new),
                              })

  end
end