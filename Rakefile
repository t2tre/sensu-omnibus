require 'rake'

STDOUT.sync = true

begin
  require 'kitchen/rake_tasks'
  Kitchen::RakeTasks.new
rescue LoadError
  puts '>>>>> Kitchen gem not loaded, omitting tasks'
end

task 'archive' do
  filedir = 'site-cookbooks/omnibus_sensu/files/default'
  archive = File.join(filedir,'archive.zip')
  `git archive --format=zip -o #{archive} HEAD`
end
