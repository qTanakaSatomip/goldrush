require 'rubygems'
namespace :gettext do
  desc 'Update pot/po files.'
  task :updatepo do
    require 'gettext/utils'
    GetText.update_pofiles('gxt',
                           Dir.glob("{app,config,lib}/**/*.{rb,rhtml}"),
                           'gxt 1.0.0'
                          )
  end

  desc 'Create mo-files'
  task :makemo do
    require 'gettext/utils'
    GetText.create_mofiles(true, 'po', 'locale')
  end
end
