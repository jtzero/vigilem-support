require 'vigilem/support/core_ext/enumerable'

require 'facets/kernel/respond'

if defined?(Delegator) and not Delegator.method_defined?(:respond)
  load Delegator.instance_method(:__getobj__).source_location.first
end

require 'facets/hash/autonew' # @todo in use?
require 'facets/string/snakecase'
require 'facets/string/titlecase'

require 'facets/enumerable/every'
