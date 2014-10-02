#####################################################################
#
# Mockingbird Event Handling -- CocoaPod Specification
#
# Created by Evan Coyne Maloney on 9/29/14.
# Copyright (c) 2014 Gilt Groupe. All rights reserved.
#
#####################################################################

Pod::Spec.new do |s|

	s.name                  = "MBEventHandling"
	s.version               = "0.9.3"
	s.summary               = "Mockingbird Event Handling Extensions"
	s.description			= "Provides a mechanism for performing runtime actions in response to NSNotification events."
	s.homepage         	    = "https://github.com/gilt/MBEventHandling"
	s.license               = { :type => 'MIT', :file => 'LICENSE' }
	s.author                = { "Evan Coyne Maloney" => "emaloney@gilt.com" }
	s.platform              = :ios, '8.0'
	s.ios.deployment_target = '7.0'
	s.requires_arc          = true

	s.source = {
		:git => 'https://github.com/gilt/MBEventHandling.git',
		:tag => s.version.to_s
	}

	s.source_files			= 'Code/**/*.{h,m}'
	s.public_header_files	= 'Code/**/*.h'

	s.xcconfig				= { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2' }

	#----------------------------------------------------------------
	# Dependencies
	#----------------------------------------------------------------

	s.dependency 'MBDataEnvironment', '~> 0.9.4'	

end
