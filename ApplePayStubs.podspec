Pod::Spec.new do |s|
  s.name         = "ApplePayStubs"
  s.version      = "0.1"
  s.summary      = "Test your Apple Pay flow without Apple Pay."
  s.description  = <<-DESC
                   ApplePayStubs lets you test your Apple Pay integration without needing an iPhone 6 and the as-yet-unreleased Apple Pay SDK.
                   DESC
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Jack Flintermann" => "jack@stripe.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/stripe/ApplePayStubs.git", :tag => "0.1" }
  s.source_files = "Classes"
  s.framework    = "PassKit"
end
