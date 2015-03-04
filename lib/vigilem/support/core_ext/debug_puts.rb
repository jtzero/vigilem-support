module Kernel
  def debug_puts(*args)
    puts "#{caller.first.rpartition(%r{/}).last}>#{args.first}", args[1..-1]
  end
end
