module Macmillan
  module Utils
    module Middleware
      autoload :WeakEtags, 'macmillan/utils/middleware/weak_etags'
      autoload :Uuid,      'macmillan/utils/middleware/uuid'
    end
  end
end
