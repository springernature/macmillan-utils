def check_config_file(filename)
  # ASSUMPTION: We are running the RSpec suite from the root of a project tree
  update_config     = true
  local_config_file = File.join(Dir.getwd, filename)

  if File.exist?(local_config_file)
    latest_conf   = File.read(File.expand_path("../../../../../#{filename}", __FILE__))
    current_conf  = File.read(local_config_file)
    update_config = false if current_conf == latest_conf
  end

  File.open(local_config_file, 'w') { |file| file.print(latest_conf) } if update_config

  update_config
end

RSpec.configure do |config|
  config.order = 'random'

  # Exit the suite on the first failure
  config.fail_fast = true if ENV['FAIL_FAST']

  config.before(:suite) do
    config_files = %w(.rubocop.yml)
    config_files << '.hound.yml' if ENV['MANAGE_HOUND']
    config_updated = config_files.map { |file| check_config_file(file) }.any?

    if config_updated
      puts 'WARNING: You do not have the latest set of Macmillan::Utils config files.'
      puts '         These have now been updated for you. :)'
      puts ''
      puts '         You can run RSpec again now.'
      puts ''
      puts "         Don't forget to commit the config files (#{config_files.join(', ')}) to git!"
      raise '...'
    end
  end
end
