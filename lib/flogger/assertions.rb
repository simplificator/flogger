module Flogger
  module InstanceMethods
    #
    # assert_flog([files_or_dir], options)
    #
    def assert_flog(*args)
      files, options = extract_files_and_options(args)
      options = {:limit => 20}.merge(options)
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
        message << "#{key.ljust(40, ' ')} has a flog score of #{value} (exceeding limit of #{options[:limit]} by #{value - options[:limit]})"
      end
      message.join("\n")
    end
    
    #
    # Remove all values which are not exceeding the limit
    #
    def reject_success(totals, options)
      totals.reject do |key, value| 
        value < options[:limit]
      end
    end
  end
end


