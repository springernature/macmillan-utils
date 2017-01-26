module Macmillan
  module Utils
    module Middleware
      autoload :CookieMessage, 'macmillan/utils/middleware/cookie_message'
      autoload :WeakEtags,     'macmillan/utils/middleware/weak_etags'
      autoload :Uuid,          'macmillan/utils/middleware/uuid'
    end
  end
end
