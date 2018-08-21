module Prawn
  module Markup
    module Support
      module Hash
        def self.deep_merge(hash, other)
          hash.merge(other) do |_key, this_val, other_val|
            if this_val.is_a?(Hash) && other_val.is_a?(Hash)
              deep_merge(this_val, other_val)
            else
              other_val
            end
          end
        end
      end
    end
  end
end
