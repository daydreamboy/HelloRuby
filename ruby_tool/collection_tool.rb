#encoding: utf-8

class Collection
  # Merge two hash
  #
  # @param  [Hash] hash1
  # @param  [Hash] hash2
  # @param  [Hash] merge_connector_info
  #         the specific connectors to concatenate value for keys. (Only for Strings)
  #
  def self.merge_hash(hash1, hash2, merge_connector_info = nil)
    hash = hash1.dup

    # hash2 => hash
    hash2.each do |k, v|
      if hash.has_key?(k)
        if v.is_a?(Hash)
          # value是Hash，递归合并
          hash[k] = merge_hash(hash[k], v)
        elsif v.is_a?(Array)
          # value是Array，不检查元素是否还是Array，直接合并去重
          hash[k] = (hash[k] + v).uniq
        elsif v.is_a?(String) && !v.eql?(hash[k])
          # value是String，检查是否相同，相同不合并，不相同合并而且用空格连接

          if merge_connector_info.nil?
            hash[k] = hash[k] + ' ' + v
          else
            if merge_connector_info[k].nil?
              hash[k] = hash[k] + ' ' + v
            else
              # 指定特定key对应value的连接符，则不使用空格
              hash[k] = hash[k] + merge_connector_info[k] + v
            end
          end

        else
          # value是其他类型（非Hash、Array、String），则忽略
        end
      else
        hash[k] = v
      end
    end

    hash
  end

end