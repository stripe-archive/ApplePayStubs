Pod::Spec.new do |s|
  s.name         = "ApplePayStubs"
  s.version      = "v0.1"
  s.summary      = "Test your Apple Pay integration without Apple Pay"

  s.description  = <<-DESC
                  ApplePayStubs lets you test your Apple Pay integration without needing an iPhone 6 and the as-yet-unreleased Apple Pay SDK.
                   DESC

  s.homepage     = "https://github.com/stripe/ApplePayStubs"
  
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = { "Stripe" => "support+github@stripe.com" }

  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/stripe/ApplePayStubs.git", :tag => s.version }

  s.source_files = "Classes", "Classes/**/*.{h,m}"
  s.exclude_files= "Classes/Exclude"
  s.framework    = "PassKit"
end
