=begin
WSDL4R - WSDL binding definition.
Copyright (C) 2002, 2003  NAKAMURA, Hiroshi.

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PRATICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program; if not, write to the Free Software Foundation, Inc., 675 Mass
Ave, Cambridge, MA 02139, USA.
=end


require 'wsdl/info'
require 'xsd/namedelements'


module WSDL


class Binding < Info
  attr_reader :name		# required
  attr_reader :type		# required
  attr_reader :operations
  attr_reader :soapbinding

  def initialize
    super
    @name = nil
    @type = nil
    @operations = XSD::NamedElements.new
    @soapbinding = nil
  end

  def targetnamespace
    parent.targetnamespace
  end

  def parse_element(element)
    case element
    when OperationName
      o = OperationBinding.new
      @operations << o
      o
    when SOAPBindingName
      o = WSDL::SOAP::Binding.new
      @soapbinding = o
      o
    when DocumentationName
      o = Documentation.new
      o
    else
      nil
    end
  end

  def parse_attr(attr, value)
    case attr
    when NameAttrName
      @name = XSD::QName.new(targetnamespace, value)
    when TypeAttrName
      @type = value
    else
      nil
    end
  end
end


end
