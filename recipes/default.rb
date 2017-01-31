#
# Cookbook:: gitlab_freebsd
# Recipe:: default
#
# Copyright:: 2017, Stefan Wendler
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

# TODO: Clean this up, maybe make thius a bunch of recipes

package 'bash'
package 'cmake'
package 'pkgconf'
package 'git'
package 'gitlab'
package 'gitlab-shell'
package 'postgresql93-client'
package 'postgresql93-server'
package 'postgresql93-contrib'
package 'nginx'

# that's a bit weird I know but if postgres is not enabled, initdb wouldn't run
execute 'sysrc postgresql_enable=YES && service postgresql initdb' do
  not_if { node['gitlab_freebsd']['postgresql']['init_done'] }
end

ruby_block 'set_postgresql_init_done_flag' do
  block do
    node.set['gitlab_freebsd']['postgresql']['init_done'] = true
  end
end

service 'postgresql' do
  supports status: true, restart: true, enable: true, start: true
  action [:enable, :start]
end

git_user = node['gitlab_freebsd']['user']
db_name = node['gitlab_freebsd']['database_yml']['database']

bash 'create_user' do
  user 'pgsql'
  code <<-EOF
    psql -d template1 -c "CREATE USER #{git_user} CREATEDB SUPERUSER;"
    psql -d template1 -c "CREATE DATABASE #{db_name} OWNER #{git_user};"
    psql -d #{db_name} -c "CREATE EXTENSION IF NOT EXISTS pg_trgm;"
  EOF
end

cookbook_file '/usr/local/etc/redis.conf' do
  source 'redis.conf'
end

group 'redis' do
  members [git_user]
  append true
  action :modify
end

service 'redis' do
  action [ :enable, :start ]
end

gitlab_dir = '/usr/local/www/gitlab'
gitlab_conf_dir = ::File.join gitlab_dir, 'config'

template ::File.join gitlab_conf_dir, 'gitlab.yml' do
  source 'gitlab.yml.erb'
  user 'root'
  group 'wheel'
  mode '444'
  variables(
    host: node['fqdn'],
    port: node['gitlab_freebsd']['gitlab_yml']['port'],
    use_https: node['gitlab_freebsd']['gitlab_yml']['use_https'],
    email_from: node['gitlab_freebsd']['gitlab_yml']['email_from'],
    email_display_name: node['gitlab_freebsd']['gitlab_yml']['email_display_name'],
    email_reply_to: node['gitlab_freebsd']['gitlab_yml']['email_reply_to']
  )
end

template ::File.join gitlab_conf_dir, 'database.yml' do
  source 'database.yml.erb'
  user 'root'
  group 'wheel'
  mode '444'
  variables(
      adapter: node['gitlab_freebsd']['database_yml']['adapter'],
      encoding: node['gitlab_freebsd']['database_yml']['encoding'],
      database: node['gitlab_freebsd']['database_yml']['database'],
      pool: node['gitlab_freebsd']['database_yml']['pool_size'],
      username: git_user,
      set_password: node['gitlab_freebsd']['database_yml']['set_password'],
      password: node['gitlab_freebsd']['database_yml']['password'],
      host: node['gitlab_freebsd']['database_yml']['host'] || node['fqdn'],
      port: node['gitlab_freebsd']['database_yml']['port']
  )
end

bash 'git_configurations_for_gitlab' do
  code <<-EOF
    git config --global core.autocrlf input
    git config --global gc.auto 0
  EOF
end

execute 'bundle install' do
  cwd gitlab_dir
  not_if { node['gitlab_freebsd']['gitlab']['is_configured'] }
end

execute 'yes yes | rake gitlab:setup RAILS_ENV=production' do
  cwd gitlab_dir
  not_if { node['gitlab_freebsd']['gitlab']['is_configured'] }
end

execute 'rake assets:precompile RAILS_ENV=production' do
  cwd gitlab_dir
  not_if { node['gitlab_freebsd']['gitlab']['is_configured'] }
end

#TODO: add password setting via rake, if attribute is true

ruby_block 'set_gitlab_is_configured_flag' do
  block do
    node.set['gitlab_freebsd']['gitlab']['is_configured'] = true
  end
end

# Under some circumstances this file exists with the wrong permissions, if it exists at all.
# But then it will lead to HTTP 500
app_log_file = ::File.join gitlab_dir, 'log/application.log'
file app_log_file do
  owner git_user
  only_if { ::File.exists? app_log_file}
end
# Somehow :start sends 'faststart', which fails ... of course
service 'gitlab' do
  start_command 'service gitlab start'
  action [:enable, :start]
end

directory '/var/log/nginx'

cookbook_file '/usr/local/etc/nginx/nginx.conf' do
  source 'nginx.conf'
  owner 'root'
  group 'wheel'
  mode '644'
  notifies :reload, 'service[nginx]', :delayed
end

service 'nginx' do
  action [:enable, :start]
end
