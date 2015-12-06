set :branch, 'master'
set :rails_env, 'production'

server '192.168.33.200', user: 'vagrant', roles: %w(web app db), password: 'vagrant'

# set :ssh_options, {
#    keys: [File.expand_path(ENV['OSS_DEPLOY_KEY_PATH'])],
#    forward_agent: true,
#    auth_methods: %w(publickey)
# }

set :ssh_options, {
  config: false
}
