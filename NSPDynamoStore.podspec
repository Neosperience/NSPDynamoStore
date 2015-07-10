Pod::Spec.new do |s|

	s.name         = "NSPDynamoStore"
	s.version      = "0.0.2"
	s.summary      = "NSPDynamoStore - Core data store for Amazon Dynamo DB"
	s.description  = <<-DESC
						This library allow to use DynamoDB as a backing store for core data contexts, also handling the sync process.
						DESC
	s.homepage     = "https://bitbucket.org/neosperience/nspdynamostore.git"
	s.license      = { :type => 'MIT', :file => 'LICENSE' }
	s.author       = { "Janos Tolgyes" => "janos.tolgyesi@neosperience.com" }

	s.platform     = :ios, '6.0'
	s.source       = { :git => "https://bitbucket.org/neosperience/nspdynamostore.git", :tag => "0.0.2" }

	s.requires_arc = true
	s.dependency 'NSPCoreUtils'

	# subspecs
	s.default_subspec = 'Main'

	#Main
	s.subspec 'Main' do |sm|
		sm.dependency 'NSPDynamoStore/Core'
		sm.dependency 'NSPDynamoStore/NSPDynamoSync'
	end
	
	#Core - NSPDynamoStore
	s.subspec 'Core' do |sm|
		sm.frameworks = 'CoreData'
		sm.dependency 'AWSiOSSDKv2'
		sm.dependency 'Bolts'
		sm.dependency 'AWSCognitoSync'
		sm.dependency 'NSPCoreUtils/NSPDefines'
		sm.dependency 'NSPCoreUtils/NSPLogger'
		sm.dependency 'NSPCoreUtils/NSPCollectionUtils'
		sm.dependency 'NSPCoreUtils/NSPTypeCheck'
		sm.source_files  = 'NSPDynamoStore/NSPDynamoStore/**/*.{h,m}'
		sm.public_header_files = 'NSPDynamoStore/NSPDynamoStore/**/*.h'
	end
	
	# NSPDynamoSync
	s.subspec 'NSPDynamoSync' do |sm|
		sm.dependency 'Bolts'
		sm.dependency 'NSPCoreUtils/NSPDefines'
		sm.dependency 'NSPCoreUtils/NSPLogger'
		sm.dependency 'NSPCoreUtils/NSPCollectionUtils'
		sm.dependency 'NSPCoreUtils/NSPTypeCheck'
		sm.dependency 'NSPCoreUtils/NSPBoltsUtils'
		sm.source_files  = 'NSPDynamoStore/NSPDynamoSync/**/*.{h,m}'
		sm.public_header_files = 'NSPDynamoStore/NSPDynamoSync/**/*.h'
	end
	
end
