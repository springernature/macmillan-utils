def check_rubocop_and_hound
  # ASSUMPTION: We are running the RSpec suite from the root of a project tree
  update_rubocop       = true
  rubocop_file         = '.rubocop.yml'
  local_rubocop_file   = File.join(Dir.getwd, rubocop_file)
  local_hound_file     = File.join(Dir.getwd, '.hound.yml')
  latest_rubocop_file  = File.expand_path("../../../../../#{rubocop_file}", __FILE__)

  if File.exist?(local_rubocop_file)
    latest_rubocop_conf  = File.read(latest_rubocop_file)
    current_rubocop_conf = File.read(local_rubocop_file)
    update_rubocop       = false if current_rubocop_conf == latest_rubocop_conf
  end

  if update_rubocop
    puts ''
    puts 'WARNING: You do not have the latest set of rubocop style preferences.'
    puts "         latest_rubocop_file: #{latest_rubocop_file}"
    puts "         local_rubocop_file:  #{local_rubocop_file}"
    puts 'diff:'
    puts ''
    puts `diff #{latest_rubocop_file} #{local_rubocop_file}`
    puts ''

  end

  if !File.exist?(local_hound_file) || !File.symlink?(local_hound_file)
    system "rm -f #{local_hound_file}"
    system "ln -s #{rubocop_file} #{local_hound_file}"
  end

  if update_rubocop
    puts 'WARNING: You do not have the latest set of rubocop style preferences.'
    puts '         These have now been updated for you. :)'
    puts ''
    puts '         You can run RSpec again now.'
    puts ''
    puts "         Don't forget to commit the '.rubocop.yml' and '.hound.yml' files to git!"

    File.open(local_rubocop_file, 'w') do |file|
      file.print latest_rubocop_conf
    end

    raise 'rubocop file was out of date'
  end
end

RSpec.configure do |config|
  config.order = 'random'

  # Exit the suite on the first failure
  config.fail_fast = true if ENV['FAIL_FAST']

  config.before(:suite) do
    check_rubocop_and_hound
  end
end
