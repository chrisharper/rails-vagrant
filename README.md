Information
===========

This is a Vagrant/Chef recipe for setting up a Rails server.

It assumes the following :
+ NGINX
+ Postgresql
+ Ruby 2.0.0
+ Rbenv
+ unicorn

Installation
============

<pre><code>
  git clone git@github.com:chrisharper/rails-vagrant.git
  cd rails-vagrant
  vi Vagrantfile #change the default attributes to fit your app details
  vagrant up
</code></pre>


Deploying
=========

Deployment is done through Capistrano with the following config files

config/deploy.rb
<pre><code>
require 'bundler/capistrano'
require 'capistrano/ext/multistage'
default_run_options[:shell] = '/bin/bash --login'

set :default_environment, { 'PATH' => "./bin:/user/local/rbenv/shims:/usr/local/rbenv/bin:$PATH" }

set :stages , %w(production staging)

set :application , 'APP_NAME'
set :repository,  'APP_NAME.git'
set :keep_releases , 5

set :user , 'dayware'
set :use_sudo , false
set :scm , :git
set :deploy_via , :remote_cache
set :deploy_to , "/var/www/APP_NAME"
set :ssh_options, { :forward_agent => true }

after 'deploy:update_code', 'deploy:migrate'
after "deploy:restart", "deploy:cleanup"
</code></pre>

config/deploy/staging.rb
<pre><code>
  set :rails_env , 'staging'
  server 'APP_URL', :app, :web, :db, :primary => true
</code></pre>

Then setup the folders and deploy with 

<pre><code>
  bundle exec cap staging deploy:setup
  bundle exec cap staging deploy
</code></pre>


Unicorn
=======

config/unicorn.rb
<pre><code>
  worker_processes 4
  timeout 15
  preload_app true

  listen "/var/www/APP_NAME/current/tmp/unicorn.sock", :backlog => 64
  pid "/var/www/APP_NAME/current/tmp/pids/unicorn.pid"
  stderr_path "/var/www/APP_NAME/current/log/unicorn.stderr.log"
  stdout_path "/var/www/APP_NAME/current/log/unicorn.stdout.log"

  before_fork do |server, worker|
    Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
  end

  after_fork do |server, worker|
    Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
  end
</code></pre>

Notes
=====

There are no backups setup.
There is no process monitor/watcher (bluepill etc)

