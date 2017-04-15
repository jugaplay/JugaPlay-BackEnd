task bulk_closing_tables: :environment do
  pid_file = '/tmp/bulk_closing_tables.pid'
  raise 'pid file exists!' if File.exists? pid_file
  File.open(pid_file, 'w'){ |file| file.puts Process.pid }
  begin
    BulkClosingTableJob.new.call
  ensure
    File.delete pid_file
  end
end
