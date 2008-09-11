module Flogger
  module InstanceMethods
    ERROR_MESSAGE_PREFIX = 'Error when flogging your files. %i methods exceeded threshold:'
    ERROR_MESSAGE = "%s has a flog score of %.2f (exceeding treshold of %.2f by %.2f)"
    
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
      failures = reject_success_and_sort(flogger.totals, options)
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
      max = failures.inject(0) {|memo, item| memo = [memo, item.first.length].max}
      message = [ERROR_MESSAGE_PREFIX % failures.size]
      failures.each do |item|
        limit = treshold_for_key(item.first, options)
        message <<  ERROR_MESSAGE % [item.first.ljust(max + 2, ' '), item.last, limit, (item.last - limit)]
      end
      message.join("\n")
    end
    
    #
    # Remove all values which are not exceeding the threshold
    #
    def reject_success_and_sort(totals, options)
      totals.reject do |key, value| 
        value < treshold_for_key(key, options)
      end.to_a.sort() {|a, b| b.last <=> a.last}
    end
    
    
    def treshold_for_key(key, options)
      options.has_key?(:tresholds) && options[:tresholds].has_key?(key) ? 
        options[:tresholds][key] : options[:treshold]
    end

  end
end


