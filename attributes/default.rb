default['gitlab_freebsd']['postgresql']['init_done'] = false
default['gitlab_freebsd']['gitlab']['is_configured'] = false

default['gitlab_freebsd']['user'] = 'git'

default['gitlab_freebsd']['gitlab_yml']['port'] = 80
default['gitlab_freebsd']['gitlab_yml']['use_https'] = false
default['gitlab_freebsd']['gitlab_yml']['email_from'] = 'gitlab@githost'
default['gitlab_freebsd']['gitlab_yml']['email_display_name'] = 'GitLab'
default['gitlab_freebsd']['gitlab_yml']['email_reply_to'] = 'gitlab@githost'

default['gitlab_freebsd']['database_yml']['adapter'] = 'postgresql'
default['gitlab_freebsd']['database_yml']['encoding'] = 'unicode'
default['gitlab_freebsd']['database_yml']['database'] = 'gitlabhq_production'
default['gitlab_freebsd']['database_yml']['pool_size'] = 10

# false on local passwordless install
default['gitlab_freebsd']['database_yml']['set_password'] = false
# set this, if set__password == true
default['gitlab_freebsd']['database_yml']['password'] = ''

# if nil, fqdn will be used. 'localhost' is a save bet for local installations
default['gitlab_freebsd']['database_yml']['host'] = 'localhost'
default['gitlab_freebsd']['database_yml']['port'] = 5432

# SET THIS PASSWORD THROUGH A VAULT! THIS VALUE IS FOR AUTOMATIC TESTING ONLY!
default['gitlab_freebsd']['root_user_password'] = 'gitlab'
