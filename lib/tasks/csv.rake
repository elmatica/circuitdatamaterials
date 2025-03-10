namespace :csv do
  task :export => :environment do
    puts MaterialDbToCsv.new.to_csv
  end

  task :dump => :environment do
    f = File.open(Rails.root.join("lib", "data", "materials.csv"), "w")
    f.write MaterialDbToCsv.new.to_csv

    f = File.open(Rails.root.join("lib", "data", "manufacturers.csv"), "w")
    f.write ManufacturerDbToCsv.new.to_csv
  end

  task :load => :environment do
    ActiveRecord::Base.connection.transaction do
      Material.delete_all
      Manufacturer.delete_all
      f = File.open(Rails.root.join("lib", "data", "manufacturers.csv"))
      ManufacturerCsvToDb.new(f.read).load_into_db

      f = File.open(Rails.root.join("lib", "data", "materials.csv"))
      MaterialCsvToDb.new(f.read).load_into_db
    end
  end
end
