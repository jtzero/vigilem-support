require 'facets/enumerable/find_yield'

# 
# 
module Enumerable
  
  # gets all execpt the parameters listed
  # on a hash this is a key
  # @see #reject
  # @param  [Array] objs
  # @return [Enumerable]
  def except(*objs)
    reject {|item| objs.include?(item) }
  end
  
  # @todo move to Array?
  # gets all except items listed at specific indexes
  # @param  [Array<Integer>] indexes
  # @return [Enumerable]
  def except_at(*indexes)
    reject.with_index {|item, idx| indexes.include?(idx) }
  end
  
  alias_method :find_result, :find_yield
end
