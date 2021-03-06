#
# Be sure to run `pod lib lint ListPaginator.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ListPaginator'
  s.version          = '1.0.2'
  s.summary          = 'ListPaginator simplifies the fetching and state management for lists of data populated from a paginated endpoint.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  ListPaginator simplifies the fetching and state management for lists of data populated from a paginated endpoint.

  Its main aims are to maintain correct page offsets, fetch statuses and retain responses from paginated API endpoints.

  Supports integration via both Swift closures and Combine publishers.
                       DESC

  s.homepage         = 'https://github.com/davefoxy/ListPaginator'
  s.swift_versions   = '5.0'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'David Fox' => '' }
  s.source           = { :git => 'https://github.com/davefoxy/ListPaginator.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/wowitzdave'

  s.ios.deployment_target = '13.0'

  s.source_files = 'Sources/**/*.swift'
end
