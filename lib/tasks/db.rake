require "fileutils"
require "dotenv"
require "sequel"

namespace :db do
  task :environment do
    ENV["APP_ENV"] ||= "development"

    require "bundler"
    Bundler.require :default, ENV["APP_ENV"].to_sym

    Dotenv.load if %w[development test].include? ENV["APP_ENV"]
  end

  task connect_db: :environment do
    DB = Sequel.connect(ENV["APP_ENV"] == "test" ? ENV["TEST_DATABASE_URL"] : ENV["DATABASE_URL"])
    DB.extension :pg_array, :pg_json
    Sequel.extension :migration
  end

  desc "Create databases"
  task create: :environment do
    %w[DATABASE_URL TEST_DATABASE_URL].each do |db_url|
      db_url = ENV[db_url]
      puts "CREATE: #{db_url}"

      if db_url.nil?
        puts "#{db_url} not set!"
        next
      end

      dbname = URI.parse(db_url).path[1..-1]
      system("createdb #{dbname}")
    end
  end

  desc "Run migrations"
  task :migrate, [:version] => :connect_db do |t, args|
    db_dir = File.join(t.application.original_dir, "db")
    migrations_dir = File.join(db_dir, "migrations")

    if args[:version]
      Sequel::Migrator.run(DB, migrations_dir, target: args[:version].to_i)
    else
      Sequel::Migrator.run(DB, migrations_dir)
    end

    if ENV["APP_ENV"] == "development"
      system("sequel -d #{ENV['DATABASE_URL']} > #{db_dir}/schema.rb")
    end

    Rake::Task["db:version"].execute
  end

  desc "Rollback to migration"
  task rollback: :connect_db do |t|
    version = if DB.tables.include?(:schema_migrations)
                previous = DB[:schema_migrations].order(Sequel.desc(:filename)).limit(2).all[1]
                previous ? previous[:filename].split("_").first : nil
              end || 0

    db_dir = File.join(t.application.original_dir, "db")
    migrations_dir = File.join(db_dir, "migrations")
    Sequel::Migrator.run(DB, migrations_dir, target: version.to_i)

    if ENV["APP_ENV"] == "development"
      system("sequel -d #{ENV['DATABASE_URL']} > #{db_dir}/schema.rb")
    end

    Rake::Task["db:version"].execute
  end

  desc "Create a migration"
  task :create_migration, [:name] => :connect_db do |t, args|
    require "date"
    raise("Name required") unless args[:name]

    timestamp = DateTime.now.strftime("%Y%m%d%H%M%S")
    migrations_dir = File.join(t.application.original_dir, "db", "migrations")
    FileUtils.mkdir_p(migrations_dir)
    path = "#{migrations_dir}/#{timestamp}_#{args[:name]}.rb"

    File.open("#{@root_dir}/#{path}", "w") do |f|
      f.write("Sequel.migration do\n  up do\n  end\n\n  down do\n  end\nend")
    end

    puts "MIGRATION CREATED: #{path}"
  end

  desc "Prints current schema version"
  task version: :connect_db do
    version = if DB.tables.include?(:schema_migrations)
                latest = DB[:schema_migrations].order(:filename).last
                latest ? latest[:filename] : nil
              end || 0

    puts "Schema Version: #{version}"
  end
end
