module LazyMethodMissing
  def method_missing(m, *args, &block)
    # better to have one line of ugliness
    # and be able to reuse this method
    # also, supress exception to return nil
    # as per the requirements
    # rubocop:disable Lint/HandleExceptions
    obj = @hash || self
    begin
      if obj[m.to_sym].nil?
        super
      else
        define_methods(m, obj)
      end
    rescue NoMethodError
      # silent fail, return nil
    end
    # rubocop:enable Lint/HandleExceptions
  end

  def define_methods(m, obj)
    value = obj[m.to_sym]
    define_singleton_method(m.to_s) { value }
    define_method("respond_to_#{m}?") { true }
    value
  end
end
