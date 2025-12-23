module ApiError
  class Unauthorized < StandardError
    DEFAULT_MESSAGE = 'Authentication required'
    def initialize(message = DEFAULT_MESSAGE)
      super(message)
    end
  end

  class Forbidden < StandardError
    DEFAULT_MESSAGE = 'You do not have permission to perform this action'
    def initialize(message = DEFAULT_MESSAGE)
      super(message)
    end
  end
end