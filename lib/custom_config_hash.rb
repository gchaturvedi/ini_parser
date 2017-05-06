require_relative("./lazy_method_missing")

class CustomConfigHash < Hash
  include LazyMethodMissing
end
