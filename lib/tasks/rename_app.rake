# frozen_string_literal: true

require 'thor'

class AppRenamer < Thor
  include Thor::Actions

  def self.source_root
    File.join(__dir__, '..', '..')
  end

  desc 'rename_application NEW_NAME', 'rename application'
  def rename_application(new_name)
    new_name_underscored = new_name.underscore

    gsub_file 'config/application.rb', 'module BaseApp', "module #{new_name}"
    gsub_file 'config/database.yml', 'base_app_development', "#{new_name_underscored}_development"
    gsub_file 'config/database.yml', 'base_app_test', "#{new_name_underscored}_test"

    gsub_file '.github/workflows/rspec.yml', 'base_app_test', "#{new_name_underscored}_test"

    gsub_file 'package.json', 'base_app', new_name_underscored
    gsub_file 'docker-compose.yml', 'base_app', new_name_underscored

    copy_file '.env.example', '.env.development.local'
    copy_file '.env.test.example', '.env.test.local'
  end
end

desc 'Rename application'
task :rename_app, [:new_name] do |_, args| # rubocop:disable Rails/RakeEnvironment
  new_name = args[:new_name]

  if new_name.present?
    app_renamer = AppRenamer.new
    app_renamer.invoke(:rename_application, [new_name])
  else
    puts "Please specify application new name - rake rename_app['BrandNewName']"
  end
end
