module Grape
  module Validations
    module Types
      # Instances of this class may be passed to
      # +Virtus::Attribute.build+ as the +:coercer+
      # option, to handle collections of types that
      # provide their own parsing (and optionally,
      # type-checking) functionality.
      #
      # See {CustomTypeCoercer} for details on types
      # that will be supported by this by this coercer.
      # This coercer works in the same way as +CustomTypeCoercer+
      # except that it expects to receive an array of strings to
      # coerce and will return an array (or optionally, a set)
      # of coerced values.
      #
      # +CustomTypeCoercer+ is already capable of providing type
      # checking for arrays where an independent coercion method
      # is supplied. As such, +CustomTypeCollectionCoercer+ does
      # not allow for such a method to be supplied independently
      # of the type.
      class CustomTypeCollectionCoercer < CustomTypeCoercer
        # A new coercer for collections of the given type.
        #
        # @param type [Class,#parse]
        #   type to which items in the array should be coerced.
        #   Must implement a +parse+ method which accepts a string,
        #   and for the purposes of type-checking it may either be
        #   a class, or it may implement a +coerced?+, +parsed?+ or
        #   +call+ method (in that order of precedence) which
        #   accepts a single argument and returns true if the given
        #   array item has been coerced correctly.
        # @param set [Boolean]
        #   when true, a +Set+ will be returned by {#call} instead
        #   of an +Array+ and duplicate items will be discarded.
        def initialize(type, set = false)
          super(type)
          @set = set
        end

        # This method is called from somewhere within
        # +Virtus::Attribute::coerce+ in order to coerce
        # the given value.
        #
        # @param value [Array<String>] an array of values to be coerced
        # @return [Array,Set] the coerced result. May be an +Array+ or a
        #   +Set+ depending on the setting given to the constructor
        def call(value)
          coerced = value.map { |item| super(item) }

          @set ? Set.new(coerced) : coerced
        end

        # This method is called from somewhere within
        # +Virtus::Attribute::value_coerced?+ in order to assert
        # that the all of the values in the array have been coerced
        # successfully.
        #
        # @param primitive [Axiom::Types::Type] primitive type for
        #   the coercion as deteced by axiom-types' inference system.
        # @param value [Enumerable] a coerced result returned from {#call}
        # @return [true,false] whether or not all of the coerced values in
        #   the collection satisfy type requirements.
        def success?(primitive, value)
          value.is_a?(@set ? Set : Array) &&
            value.all? { |item| super(primitive, item) }
        end
      end
    end
  end
end
