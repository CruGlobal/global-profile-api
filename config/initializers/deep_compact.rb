# frozen_string_literal: true

class Hash
  def deep_compact!
    reject! do |_, v|
      if v.respond_to?("deep_compact!")
        v.deep_compact!
        v.empty?
      else
        v.nil?
      end
    end
  end
end

class Array
  def deep_compact!
    reject! do |v|
      if v.respond_to?("deep_compact!")
        v.deep_compact!
        v.empty?
      else
        v.nil?
      end
    end
  end
end
