#!/usr/bin/env ruby

$serverName = 'SoapRMI'

require 'clientBase'

$server = 'http://rainier.extreme.indiana.edu:1568'
$soapAction = 'urn:soapinterop'

drv = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )

methodDef( drv )

doTest( drv )