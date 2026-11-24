# Metron from the command line, for development and the demo:
#   bin/rails "metron:search[Saga]"
#   bin/rails "metron:import[1234]"
namespace :metron do
  desc "Search Metron for a series by name"
  task :search, [ :name ] => :environment do |_task, args|
    MetronImport.client.search_series(args.fetch(:name)).first(10).each do |row|
      puts "#{row["id"].to_s.rjust(7)}  #{row["series"]}"
    end
  end

  desc "Import a series and its issues from Metron, by its Metron id"
  task :import, [ :metron_id ] => :environment do |_task, args|
    series = MetronImport.new.import_series(args.fetch(:metron_id))
    puts "Imported #{series.display_name}: #{series.issues.count} issues"
  end
end
