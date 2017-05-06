require_relative('./lazy_method_missing')

module INI
  # The ConfigObj is instantiated with a given
  # hash.  Lazily defines methods as queries come in.
  # This ensures the CONFIG object can be returned as fast
  # as possible, but at the same time ensures that
  # queries that are made often will be fast (method will
  # be defined after first invocation)
  class ConfigObject
    include LazyMethodMissing

    def initialize(hash)
      @hash = hash
    end
  end
end
