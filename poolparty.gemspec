
# Gem::Specification for Poolparty-0.0.9
# Originally generated by Echoe

--- !ruby/object:Gem::Specification 
name: poolparty
version: !ruby/object:Gem::Version 
  version: 0.0.9
platform: ruby
authors: 
- Ari Lerner
autorequire: 
bindir: bin

date: 2008-06-27 00:00:00 -07:00
default_executable: 
dependencies: 
- !ruby/object:Gem::Dependency 
  name: aws-s3
  type: :runtime
  version_requirement: 
  version_requirements: !ruby/object:Gem::Requirement 
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        version: "0"
    version: 
- !ruby/object:Gem::Dependency 
  name: amazon-ec2
  type: :runtime
  version_requirement: 
  version_requirements: !ruby/object:Gem::Requirement 
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        version: "0"
    version: 
- !ruby/object:Gem::Dependency 
  name: auser-aska
  type: :runtime
  version_requirement: 
  version_requirements: !ruby/object:Gem::Requirement 
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        version: "0"
    version: 
- !ruby/object:Gem::Dependency 
  name: git
  type: :runtime
  version_requirement: 
  version_requirements: !ruby/object:Gem::Requirement 
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        version: "0"
    version: 
- !ruby/object:Gem::Dependency 
  name: crafterm-sprinkle
  type: :runtime
  version_requirement: 
  version_requirements: !ruby/object:Gem::Requirement 
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        version: "0"
    version: 
- !ruby/object:Gem::Dependency 
  name: SystemTimer
  type: :runtime
  version_requirement: 
  version_requirements: !ruby/object:Gem::Requirement 
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        version: "0"
    version: 
- !ruby/object:Gem::Dependency 
  name: echoe
  type: :development
  version_requirement: 
  version_requirements: !ruby/object:Gem::Requirement 
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        version: "0"
    version: 
description: Run your entire application off EC2, managed and auto-scaling
email: ari.lerner@citrusbyte.com
executables: 
- instance
- pool
- poolnotify
extensions: []

extra_rdoc_files: 
- bin/instance
- bin/pool
- bin/poolnotify
- CHANGELOG
- lib/core/array.rb
- lib/core/exception.rb
- lib/core/float.rb
- lib/core/hash.rb
- lib/core/kernel.rb
- lib/core/module.rb
- lib/core/object.rb
- lib/core/proc.rb
- lib/core/string.rb
- lib/core/time.rb
- lib/modules/callback.rb
- lib/modules/ec2_wrapper.rb
- lib/modules/file_writer.rb
- lib/modules/safe_instance.rb
- lib/modules/sprinkle_overrides.rb
- lib/modules/vlad_override.rb
- lib/poolparty/application.rb
- lib/poolparty/init.rb
- lib/poolparty/master.rb
- lib/poolparty/monitors/cpu.rb
- lib/poolparty/monitors/memory.rb
- lib/poolparty/monitors/web.rb
- lib/poolparty/monitors.rb
- lib/poolparty/optioner.rb
- lib/poolparty/plugin.rb
- lib/poolparty/plugin_manager.rb
- lib/poolparty/provider/packages/essential.rb
- lib/poolparty/provider/packages/git.rb
- lib/poolparty/provider/packages/haproxy.rb
- lib/poolparty/provider/packages/heartbeat.rb
- lib/poolparty/provider/packages/monit.rb
- lib/poolparty/provider/packages/rsync.rb
- lib/poolparty/provider/packages/ruby.rb
- lib/poolparty/provider/packages/s3fuse.rb
- lib/poolparty/provider/provider.rb
- lib/poolparty/provider.rb
- lib/poolparty/remote_instance.rb
- lib/poolparty/remoter.rb
- lib/poolparty/remoting.rb
- lib/poolparty/scheduler.rb
- lib/poolparty/tasks/cloud.rake
- lib/poolparty/tasks/development.rake
- lib/poolparty/tasks/ec2.rake
- lib/poolparty/tasks/instance.rake
- lib/poolparty/tasks/plugins.rake
- lib/poolparty/tasks/server.rake
- lib/poolparty/tasks.rb
- lib/poolparty/tmp.rb
- lib/poolparty.rb
- lib/s3/s3_object_store_folders.rb
- README.txt
files: 
- assets/clouds.png
- bin/instance
- bin/pool
- bin/poolnotify
- CHANGELOG
- config/cloud_master_takeover
- config/create_proxy_ami.sh
- config/haproxy.conf
- config/heartbeat.conf
- config/heartbeat_authkeys.conf
- config/installers/ubuntu_install.sh
- config/monit/haproxy.monit.conf
- config/monit/nginx.monit.conf
- config/monit.conf
- config/nginx.conf
- config/reconfigure_instances_script.sh
- config/sample-config.yml
- config/scp_instances_script.sh
- lib/core/array.rb
- lib/core/exception.rb
- lib/core/float.rb
- lib/core/hash.rb
- lib/core/kernel.rb
- lib/core/module.rb
- lib/core/object.rb
- lib/core/proc.rb
- lib/core/string.rb
- lib/core/time.rb
- lib/modules/callback.rb
- lib/modules/ec2_wrapper.rb
- lib/modules/file_writer.rb
- lib/modules/safe_instance.rb
- lib/modules/sprinkle_overrides.rb
- lib/modules/vlad_override.rb
- lib/poolparty/application.rb
- lib/poolparty/init.rb
- lib/poolparty/master.rb
- lib/poolparty/monitors/cpu.rb
- lib/poolparty/monitors/memory.rb
- lib/poolparty/monitors/web.rb
- lib/poolparty/monitors.rb
- lib/poolparty/optioner.rb
- lib/poolparty/plugin.rb
- lib/poolparty/plugin_manager.rb
- lib/poolparty/provider/packages/essential.rb
- lib/poolparty/provider/packages/git.rb
- lib/poolparty/provider/packages/haproxy.rb
- lib/poolparty/provider/packages/heartbeat.rb
- lib/poolparty/provider/packages/monit.rb
- lib/poolparty/provider/packages/rsync.rb
- lib/poolparty/provider/packages/ruby.rb
- lib/poolparty/provider/packages/s3fuse.rb
- lib/poolparty/provider/provider.rb
- lib/poolparty/provider.rb
- lib/poolparty/remote_instance.rb
- lib/poolparty/remoter.rb
- lib/poolparty/remoting.rb
- lib/poolparty/scheduler.rb
- lib/poolparty/tasks/cloud.rake
- lib/poolparty/tasks/development.rake
- lib/poolparty/tasks/ec2.rake
- lib/poolparty/tasks/instance.rake
- lib/poolparty/tasks/plugins.rake
- lib/poolparty/tasks/server.rake
- lib/poolparty/tasks.rb
- lib/poolparty/tmp.rb
- lib/poolparty.rb
- lib/s3/s3_object_store_folders.rb
- Manifest
- poolparty.gemspec
- Rakefile
- README.txt
- spec/application_spec.rb
- spec/callback_spec.rb
- spec/core_spec.rb
- spec/ec2_wrapper_spec.rb
- spec/file_writer_spec.rb
- spec/files/describe_response
- spec/files/multi_describe_response
- spec/files/remote_desc_response
- spec/helpers/ec2_mock.rb
- spec/kernel_spec.rb
- spec/master_spec.rb
- spec/monitors/cpu_monitor_spec.rb
- spec/monitors/memory_spec.rb
- spec/monitors/misc_monitor_spec.rb
- spec/monitors/web_spec.rb
- spec/optioner_spec.rb
- spec/plugin_manager_spec.rb
- spec/plugin_spec.rb
- spec/pool_binary_spec.rb
- spec/poolparty_spec.rb
- spec/provider_spec.rb
- spec/remote_instance_spec.rb
- spec/remoter_spec.rb
- spec/remoting_spec.rb
- spec/scheduler_spec.rb
- spec/spec_helper.rb
- spec/string_spec.rb
- vendor/pool-party-plugins/deployment/capistrano/deploy_tasks.rb
- vendor/pool-party-plugins/deployment/capistrano/init.rb
- vendor/pool-party-plugins/deployment/capistrano/master_capistrano.rb
- vendor/pool-party-plugins/deployment/capistrano/master_capistrano_spec.rb
- vendor/pool-party-plugins/deployment/vlad/deploy_task.rb
- vendor/pool-party-plugins/deployment/vlad/init.rb
- vendor/pool-party-plugins/deployment/vlad/Rakefile
- vendor/pool-party-plugins/deployment/vlad/vladder.rb
- vendor/pool-party-plugins/deployment/vlad/vladder_spec.rb
- vendor/pool-party-plugins/maintenance/dnsmadeeasy/config.yml
- vendor/pool-party-plugins/maintenance/dnsmadeeasy/dns.rb
- vendor/pool-party-plugins/maintenance/dnsmadeeasy/init.rb
- vendor/pool-party-plugins/maintenance/dyndns/config.yml
- vendor/pool-party-plugins/maintenance/dyndns/dns.rb
- vendor/pool-party-plugins/maintenance/dyndns/init.rb
- vendor/pool-party-plugins/maintenance/zoneedit/config.yml
- vendor/pool-party-plugins/maintenance/zoneedit/dns.rb
- vendor/pool-party-plugins/maintenance/zoneedit/init.rb
- vendor/pool-party-plugins/monitoring/logging/init.rb
- vendor/pool-party-plugins/monitoring/logging/logging.rb
- vendor/pool-party-plugins/monitoring/logging/logging_spec.rb
- vendor/pool-party-plugins/README
- vendor/pool-party-plugins/spec/helpers/ec2_mock.rb
- vendor/pool-party-plugins/spec/spec_helper.rb
has_rdoc: true
homepage: http://blog.citrusbyte.com
post_install_message: "    \n    Thanks for installing PoolParty!\n    \n    Please check out the documentation for any questions or check out the google groups at\n      http://groups.google.com/group/poolpartyrb\n    \n    Don't forget to check out the plugin tutorial @ http://poolpartyrb.com for extending PoolParty!\n    \n    For more information, check http://poolpartyrb.com\n    On IRC: \n      irc.freenode.net\n      #poolpartyrb\n    *** Ari Lerner @ <ari.lerner@citrusbyte.com> ***\n    \n"
rdoc_options: 
- --line-numbers
- --inline-source
- --title
- Poolparty
- --main
- README.txt
require_paths: 
- lib
required_ruby_version: !ruby/object:Gem::Requirement 
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      version: "0"
  version: 
required_rubygems_version: !ruby/object:Gem::Requirement 
  requirements: 
  - - "="
    - !ruby/object:Gem::Version 
      version: "1.2"
  version: 
requirements: []

rubyforge_project: poolparty
rubygems_version: 1.2.0
specification_version: 2
summary: Run your entire application off EC2, managed and auto-scaling
test_files: []
