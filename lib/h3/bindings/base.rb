module H3
  module Bindings
    # Base for FFI Bindings.
    #
    # When extended, this module sets up FFI to use the H3 C library.
    module Base
      def self.extended(base)
        base.extend FFI::Library
        base.extend Gem::Deprecate
        base.include Structs
        base.include Types
        base.ffi_lib ["#{lib_path}/libh3.dylib", "#{lib_path}/libh3.so", "libh3"]
        base.typedef :ulong_long, :h3_index
        base.typedef :int, :k_distance
      end

      def self.lib_path
        arch = RbConfig::CONFIG['host_cpu']
        native_path = File.expand_path(__dir__ + "/../../../lib/h3/native")

        if arch =~ /x86_64/
          "#{native_path}/libh3-x86_64.so"
        elsif arch =~ /aarch64|arm64/
          "#{native_path}/libh3-aarch64.so"
        else
          "libh3"
        end
      end

      def attach_predicate_function(name, *args)
        stripped_name = name.to_s.gsub("?", "")
        attach_function(stripped_name, *args).tap do
          rename_function stripped_name, name
        end
      end

      private

      def rename_function(from, to)
        alias_method to, from
        undef_method from
      end
    end
  end
end
