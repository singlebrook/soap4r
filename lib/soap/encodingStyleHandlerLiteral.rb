=begin
SOAP4R - XML Literal EncodingStyle handler library
Copyright (C) 2001 NAKAMURA Hiroshi.

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

require 'soap/encodingStyleHandler'


module SOAP


class EncodingStyleHandlerLiteral < EncodingStyleHandler

  Namespace = 'http://xml.apache.org/xml-soap/literalxml'

  def initialize
    super( Namespace )
    @textBuf = ''
  end


  ###
  ## encode interface.
  #
  def encodeData( buf, ns, qualified, data, parent )
    attrs = {}
    name = nil
    if qualified and data.namespace
      if !ns.assigned?( data.namespace )
        tag = ns.assign( data.namespace )
        attrs[ 'xmlns:' << tag ] = data.namespace
      end
      name = ns.name( data.namespace, data.name )
    else
      name = data.name
    end

    case data
    when SOAPBasetype
      SOAPGenerator.encodeTag( buf, name, attrs, false )
      buf << SOAPGenerator.encodeStr( data.to_s )
    when SOAPStruct
      SOAPGenerator.encodeTag( buf, name, attrs, true )
      data.each do | key, value |
	value.namespace = data.namespace if !value.namespace
        yield( value, true )
      end
    when SOAPArray
      SOAPGenerator.encodeTag( buf, name, attrs, true )
      data.traverse do | child, *rank |
	data.position = nil
        yield( child, true )
      end
    else
      raise EncodingStyleError.new( "Unknown object:#{ data } in this encodingSt
yle." )
    end
  end

  def encodeDataEnd( buf, ns, qualified, data, parent )
    name = nil
    if qualified and data.namespace
      name = ns.name( data.namespace, data.name )
    else
      name = data.name
    end
    SOAPGenerator.encodeTagEnd( buf, name, true )
  end


  ###
  ## decode interface.
  #
  class SOAPTemporalObject
    attr_accessor :parent

    def initialize
      @parent = nil
    end
  end

  class SOAPUnknown < SOAPTemporalObject
    def initialize( handler, ns, name )
      super()
      @handler = handler
      @ns = ns
      @name = name
    end

    def toStruct
      o = SOAPStruct.decode( @ns, @name, XSD::Namespace, XSD::AnyTypeLiteral )
      o.parent = @parent
      @handler.decodeParent( @parent, o )
      o
    end

    def toString
      o = SOAPString.decode( @ns, @name )
      o.parent = @parent
      @handler.decodeParent( @parent, o )
      o
    end

    def toNil
      o = SOAPNil.decode( @ns, @name )
      o.parent = @parent
      @handler.decodeParent( @parent, o )
      o
    end
  end

  def decodeTag( ns, name, attrs, parent )
    # ToDo: check if @textBuf is empty...
    @textBuf = ''
    o = SOAPUnknown.new( self, ns, name )
    o.parent = parent
    o
  end

  def decodeTagEnd( ns, node )
    o = node.node
    if o.is_a?( SOAPUnknown )
      newNode = if /\A\s*\z/ =~ @textBuf
	  o.toStruct
	else
	  o.toString
	end
      node.replaceNode( newNode )
      o = node.node
    end

    decodeTextBuf( o )
    @textBuf = ''
  end

  def decodeText( ns, text )
    # @textBuf is set at decodeTagEnd.
    @textBuf << text
  end

  def decodePrologue
  end

  def decodeEpilogue
  end

  def decodeParent( parent, node )
    case parent.node
    when SOAPUnknown
      newParent = parent.node.toStruct
      node.parent = newParent
      parent.replaceNode( newParent )
      decodeParent( parent, node )

    when SOAPStruct
      parent.node.add( node.name, node )

    when SOAPArray
      if node.position
	parent.node[ *( decodeArrayPosition( node.position )) ] = node
	parent.node.sparse = true
      else
	parent.node.add( node )
      end

    when SOAPBasetype
      raise EncodingStyleError.new( "SOAP base type must not have a child." )

    else
      # SOAPUnknown does not have parent.
      # raise EncodingStyleError.new( "Illegal parent: #{ parent }." )
    end
  end

private

  def decodeTextBuf( node )
    if node.is_a?( XSDString )
      encoded = Charset.encodingFromXML( @textBuf )
      node.set( encoded )
    else
      # Nothing to do...
    end
  end
end

EncodingStyleHandlerLiteral.new


end