# WSDL4R - XMLSchema complexType extension definition for WSDL.
# Copyright (C) 2005  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'
require 'xsd/namedelements'


module WSDL
module XMLSchema


class ComplexExtension < Info
  attr_accessor :base
  attr_reader :content
  attr_reader :attributes

  def initialize
    super
    @base = nil
    @basetype = nil
    @content = nil
    @attributes = XSD::NamedElements.new
  end

  def targetnamespace
    parent.targetnamespace
  end

  def elementformdefault
    parent.elementformdefault
  end

  def elements
    result = XSD::NamedElements.new
    result.concat(basetype.elements)
    result.concat(content.elements) if content
    result
  end

  def check_type
    if @base == ::SOAP::ValueArrayName
      :TYPE_ARRAY
    else
      basetype.check_type
    end
  end
  
  def parse_element(element)
    case element
    when AllName
      @content = All.new
      @content
    when SequenceName
      @content = Sequence.new
      @content
    when ChoiceName
      @content = Choice.new
      @content
    when AttributeName
      o = Attribute.new
      @attributes << o
      o
    end
  end

  def parse_attr(attr, value)
    case attr
    when BaseAttrName
      @base = value
    end
  end

private

  def basetype
    @basetype ||= root.collect_complextypes[@base]
  end
end


end
end