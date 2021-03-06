module Reek
  module AST
    module SexpExtensions
      # Base module for utility methods for :def and :defs nodes.
      module MethodNodeBase
        def arguments
          parameters.reject(&:block?)
        end

        def arg_names
          arguments.map(&:name)
        end

        def parameters
          argslist.components
        end

        def parameter_names
          parameters.map(&:name)
        end

        def name_without_bang
          name.to_s.chop
        end

        def ends_with_bang?
          name[-1] == '!'
        end

        def body_nodes(types, ignoring = [])
          if body
            body.find_nodes(types, ignoring)
          else
            []
          end
        end
      end

      # Checking if a method is a singleton method.
      module SingletonMethod
        def singleton_method?
          singleton_method_via_class_self_notation?
        end

        # Ruby allows us to make a method a singleton_method using the
        # class << self syntax.
        #
        # To check for this we check if the parent node is of type :sclass.
        #
        # @return [Boolean]
        def singleton_method_via_class_self_notation?
          return unless parent
          parent.type == :sclass
        end
      end

      # Utility methods for :def nodes.
      module DefNode
        include MethodNodeBase
        include SingletonMethod

        def name
          children.first
        end

        def argslist
          children[1]
        end

        def body
          children[2]
        end

        def full_name(outer)
          [outer, name].reject(&:empty?).join('#')
        end

        def depends_on_instance?
          ReferenceCollector.new(self).num_refs_to_self > 0
        end
      end

      # Utility methods for :defs nodes.
      module DefsNode
        include MethodNodeBase

        def receiver
          children.first
        end

        def name
          children[1]
        end

        def argslist
          children[2]
        end

        def body
          children[3]
        end

        def full_name(outer)
          prefix = outer == '' ? '' : "#{outer}#"
          "#{prefix}#{SexpFormatter.format(receiver)}.#{name}"
        end

        def depends_on_instance?
          false
        end
      end
    end
  end
end
