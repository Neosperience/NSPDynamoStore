Pod::Spec.new do |s|

	s.name         = "NSPDynamoStore"
	s.version      = "0.0.5"
	s.summary      = "NSPDynamoStore - Core data store for Amazon Dynamo DB"
	s.description  = <<-DESC
						This library allow to use DynamoDB as a backing store for core data contexts, also handling the sync process.
						DESC
	s.homepage     = "https://github.com/Neosperience/NSPDynamoStore"
	s.license      = { :type => 'MIT', :file => 'LICENSE' }
	s.author       = { "Janos Tolgyesi" => "janos.tolgyesi@neosperience.com" }

	s.platform     = :ios, '7.0'
	s.source       = { :git => "https://github.com/Neosperience/NSPDynamoStore.git", :tag => "0.0.5" }

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
		sm.dependency 'AWSCore', '~> 2.2'
		sm.dependency 'AWSiOSSDKv2', '~> 2.2'
		sm.dependency 'AWSDynamoDB', '~> 2.2'
		sm.dependency 'Bolts'
		sm.dependency 'AWSCognito'
		sm.dependency 'NSPCoreUtils/NSPDefines'
		sm.dependency 'NSPCoreUtils/NSPLogger'
		sm.dependency 'NSPCoreUtils/NSPCollectionUtils'
		sm.dependency 'NSPCoreUtils/NSPTypeCheck'
		sm.dependency 'NSPCoreUtils/NSPBoltsUtils'
		sm.source_files  = 'NSPDynamoStore/**/*.{h,m}'
		sm.public_header_files = 'NSPDynamoStore/**/*.h'
	end

	# NSPDynamoSync
	s.subspec 'NSPDynamoSync' do |sm|
		sm.dependency 'Bolts'
		sm.dependency 'NSPDynamoStore/Core'
		sm.dependency 'NSPCoreUtils/NSPDefines'
		sm.dependency 'NSPCoreUtils/NSPLogger'
		sm.dependency 'NSPCoreUtils/NSPCollectionUtils'
		sm.dependency 'NSPCoreUtils/NSPTypeCheck'
		sm.dependency 'NSPCoreUtils/NSPBoltsUtils'
		sm.source_files  = 'NSPDynamoSync/**/*.{h,m}'
		sm.public_header_files = 'NSPDynamoSync/**/*.h'
	end

end
