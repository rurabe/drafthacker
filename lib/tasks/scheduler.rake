desc "This task is called by the Heroku scheduler add-on"
task :update_players => :environment do
    puts "Populating players db with new data..."
    Cbs::Players.populate #should be upgraded to update
    puts "done."
end