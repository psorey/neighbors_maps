  class String
    def dashed
      self.downcase.gsub(/\s+/, '_')
    end
  end
