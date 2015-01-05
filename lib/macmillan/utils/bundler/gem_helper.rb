module Bundler
  class GemHelper
    def rubygem_push(path)
      gem_server_url = 'http://gems.npgsrv.com'
      sh("gem inabox '#{path}' --host #{gem_server_url}")
      Bundler.ui.confirm "Pushed #{name} #{version} to #{gem_server_url}"
    end
  end
end
