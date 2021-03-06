task :cruise => %w(testing db:migrate:reset test cap_staging_deploy)

task :cap_staging_deploy => :environment  do
  `cap staging deploy`
  raise "Error deploying to staging" if $?.exitstatus == 1
  `cap staging deploy:migrate`
  raise "Error migrating staging database" if $?.exitstatus == 1
  `cap staging ultrasphinx`
  raise "Error configuring and indexing staging sphinx" if $?.exitstatus == 1
  `cap staging deploy:restart`
  raise "Error restarting servers" if $?.exitstatus == 1
end
