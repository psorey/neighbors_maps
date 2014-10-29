  class String
    def dashed
      self.downcase.gsub(/\s+/, '_')
    end
  end


module LogBuddy
  module Utils

    def debug(obj)
      return if @disabled
      str = obj_to_string(obj)
      stdout_puts(str) if log_to_stdout?
      logger.debug("\e[0;100m"+str)
    end

    def arg_and_blk_debug(arg, blk)
      result = eval(arg, blk.binding)
      result_str = obj_to_string(result, :quote_strings => true)
      #LogBuddy.debug("\[\033[40m\]#{arg} = #{result_str}\n\[\033[00m\]")
      LogBuddy.debug("\e[0;100m#{arg} = #{result_str}\n\[\033[00m\]")
    end
  end
end
