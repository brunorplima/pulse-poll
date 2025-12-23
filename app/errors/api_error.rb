module ApiError
  class Unauthorized < StandardError
    DEFAULT_MESSAGE = 'Authentication required'.freeze
    def initialize(message = DEFAULT_MESSAGE)
      super
    end
  end

  class Forbidden < StandardError
    DEFAULT_MESSAGE = 'You do not have permission to perform this action'.freeze
    def initialize(message = DEFAULT_MESSAGE)
      super
    end
  end
end
