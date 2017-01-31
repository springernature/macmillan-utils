require 'colorize'

def check_config_file(filename)
  # ASSUMPTION: We are running the RSpec suite from the root of a project tree
  update_config     = true
  local_config_file = File.join(Dir.getwd, filename)

  if File.exist?(local_config_file)
    @message ||= []

    latest_conf_path = File.expand_path("../../../../../#{filename}", __FILE__)
    latest_conf      = File.read(latest_conf_path)
    @message << "macmillan-utils config file = #{latest_conf_path}"

    current_conf = File.read(local_config_file)
    @message << "current repo config file = #{local_config_file}"

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
      puts "\nWARNING: Your local config file(s) have been replaced with the versions \n"\
           "from macmillan-utils gem, on the assumption macmillan-utils is up-to-date.\n"\
           "\nIf you see this failure on *CI*, you may want to run *locally*: \n"\
           "$ bundle update macmillan-utils \n"\
           "before re-running the specs, then committing and pushing the updated configs.\n".red

      @message.each do |msg|
        puts "Please note: \n #{msg}".red
      end

      puts "\nYou can now re-run RSpec without this failure interfering.".red

      raise '...'
    end
  end
end
