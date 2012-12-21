require 'yaml'

class String
  def is_binary_data?
    false
  end

  def decode
    gsub(/\\x(\w{2})/){[Regexp.last_match.captures.first.to_i(16)].pack("C")}
  end
end

ObjectSpace.each_object(Class){|klass|
  klass.class_eval{
    if method_defined?(:to_yaml) && !method_defined?(:to_yaml_with_decode)
      def to_yaml_with_decode(*args)
        result = to_yaml_without_decode(*args)
        if result.kind_of? String
          result.decode
        else
          result
        end
      end
      alias_method :to_yaml_without_decode, :to_yaml
      alias_method :to_yaml, :to_yaml_with_decode
    end
  }
}

namespace :db do
  namespace :fixtures do
    def selectable_fixtures(dir_name)
      require 'active_record/fixtures'
      ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
      (ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/) : Dir.glob(File.join(RAILS_ROOT, 'fixtures', dir_name, '*.{yml,csv}'))).each do |fixture_file|
        Fixtures.create_fixtures(File.join('fixtures', dir_name), File.basename(fixture_file, '.*'))
      end
    end

    desc "Load initial fixtures into the current environment's database.  Load specific fixtures using FIXTURES=x,y [DIR=demo]"
    task :init => :environment do
      fixdir = ENV['DIR'] || 'init'
      selectable_fixtures fixdir
    end

    desc "Load development fixtures into the current environment's database.  Load specific fixtures using FIXTURES=x,y"
    task :develop => :environment do
      selectable_fixtures 'develop'
    end

    desc "Dump fixtures from the current environment's database.  Dump specific tables using TABLES=x,y"
    task :dump => :environment do
      ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
      ENV['TABLES'].split(/,/).each do |fixture_table|
        claz = eval(fixture_table.classify)
        File.open(File.join(RAILS_ROOT, 'test', 'fixtures', fixture_table + '.yml'), 'w'){|f|
          claz.find(:all, :order => 'id').each{|x|
            f << "#{fixture_table}_#{x.id}:\n"
            first = true
            x.attributes.to_yaml.each{|y|
              if first
                first = false
                next
              end
              f << '  ' + y
            }
          }
        }
      end
    end
  end
end
