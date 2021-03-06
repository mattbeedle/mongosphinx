# MongoSphinx, a full text indexing extension for MongoDB using
# Sphinx.
#
# This file contains the MongoSphinx::MultiAttribute class.

# Namespace module for the MongoSphinx gem.

module MongoSphinx #:nodoc:

  # Module MultiAttribute implements helpers to translate back and
  # forth between Ruby Strings and an array of integers suitable for Sphinx
  # attributes of type "multi".
  #
  # Background: Getting an ID as result for a query is OK, but for example to
  # allow cast safety, we need an aditional attribute. Sphinx supports
  # attributes which are returned together with the ID, but they behave a
  # little different than expected: Instead we can use arrays of integers with
  # ASCII character codes. These values are returned in ascending (!) order of
  # value (yes, sounds funny but is reasonable from an internal view to
  # Sphinx). So we mask each byte with 0x0100++ to keep the order...
  #
  # Sample:
  #
  #   MongoSphinx::MultiAttribute.encode('Hello')
  #   => "328,613,876,1132,1391"
  #   MongoSphinx::MultiAttribute.decode('328,613,876,1132,1391')
  #   => "Hello"

  module MultiAttribute

    # Returns an numeric representation of a Ruby String suitable for "multi"
    # attributes of Sphinx.
    #
    # Parameters:
    #
    # [str] String to translate

    def self.encode(str)
      offset = 0
      if str.respond_to?"bytes"
        bytes = str.bytes
      else
        bytes = []
        str.each_byte{|x| bytes << x}
      end
      return bytes.collect { |c| (offset+= 0x0100) + c }.join(',')
    end

    # Returns the original MongoDB ID created from a Sphinx ID. Only works if
    # the ID was created from a MongoDB ID before!
    #
    # Parameters:
    #
    # [multi] Sphinx "multi" attribute to translate back

    def self.decode(multi)
      offset = 0
      multi = multi.split(',') if not multi.kind_of? Array

      return multi.collect {|x| (x.to_i-(offset+=0x0100)).chr}.join
    end
  end
end
