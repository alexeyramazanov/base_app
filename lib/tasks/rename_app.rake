require 'thor'

class AppRenamer < Thor
  include Thor::Actions

  desc 'rename_application NEW_NAME', 'rename applicaiton'
  def rename_application(new_name)
    new_name_underscored = new_name.underscore

    gsub_file 'config/application.rb', 'module BaseApp', "module #{new_name}"
    gsub_file 'config/initializers/session_store.rb', '_base_app_session', "_#{new_name_underscored}_session"
  end
end

desc 'Rename application'
task :rename_app, [:new_name] do |_, args|
  new_name = args[:new_name]

  if new_name.present?
    app_renamer = AppRenamer.new
    app_renamer.invoke(:rename_application, [new_name])
  else
    puts "Please specify application new name - rake rename_app['BrandNewName']"
  end
end
