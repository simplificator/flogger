module Flogger
  module InstanceMethods
    # 
    # assert the flog score of file(s) is below a treshold (default treshold is 20).
    # 
    # = Samples:
    # == Flog a file or all ruby files in a directory
    # assert_flog(file_or_dir)
    # == Flog several files or directories
    # assert_flog(file_or_dir_1, file_or_dir_2, file_or_fir_n)
    # == set your own flog threshold
    # assert_flog(file_or_dir, :threshold => 20)
    # == set your own flog threshold for a specific method
    # assert_flog(file_or_dir, :thresholds => {'FooClass#bar_method'})
    # 
    # == options
    #  * :treshold what flog score do we allow at most. Default is 20.
    #  * :tresholds customize tresholds on a per class/method base, overrides :treshold option
    # 
    # == Message
    # This assertion does not support passing in your own message like 
    # other assertions do (optional last parameter) because the error message 
    # lists all failures from flog.
    #
    def assert_flog(*args)
      files, options = extract_files_and_options(args)
      options = {:treshold => 20}.merge(options)
      flogger = Flog.new()
      flogger.flog_files(files)
      failures = reject_success(flogger.totals, options)
      assert_block(build_flog_message(failures, options)) do
        failures.size == 0
      end
    end
    
    private
    
    #
    # Extracts an optional Hash (options) from an Array of Strings
    #
    def extract_files_and_options(args)
      raise ArgumentError.new('To few argumnets') if args.size < 1
      if args.size == 1 || args.last.is_a?(String)
        [args, {}]
      else
        [args[0...-1], args.last]
      end
    end
    #
    # Builds a 'nice' error message listing all failed methods
    #
    def build_flog_message(failures, options)
      message = ['Error when flogging your files:']
      failures.each do |key, value|
        limit = treshold_for_key(key, options)
        message << "#{key.ljust(40, ' ')} has a flog score of #{value} (exceeding treshold of #{limit} by #{value - limit})"
      end
      message.join("\n")
    end
    
    #
    # Remove all values which are not exceeding the threshold
    #
    def reject_success(totals, options)
      totals.reject do |key, value| 
        value < treshold_for_key(key, options)
      end
    end
    
    
    def treshold_for_key(key, options)
      options.has_key?(:tresholds) && options[:tresholds].has_key?(key) ? 
        options[:tresholds][key] : options[:treshold]
    end

  end
end


