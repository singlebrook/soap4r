#!/usr/bin/env ruby

$serverName = 'Apache Axis'
$serverBase = 'http://nagoya.apache.org:5049/axis/servlet/AxisServlet'
$serverGroupB = 'None'

require 'clientBase'

drvBase = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverBase, $proxy, $soapAction )
methodDefBase( drvBase )

#drvGroupB = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverGroupB, $proxy, $soapAction )
#methodDefGroupB( drvGroupB )

$test_echoMap = true

doTestBase( drvBase )
#doTestGroupB( drvGroupB )
submitTestResult