task :cron => :environment do
  Rake::Task['purge_deleted_lists'].execute
end


task :purge_deleted_lists => :environment do
  puts 'removing lists that have been logically deleted for at least 12 hours...'
  lists_removed = ActiveRecord::SessionStore::List.delete_all(["deleted = true AND deleted_since < ?", 12.hours.ago])
  puts lists_removed + ' removed'
end
