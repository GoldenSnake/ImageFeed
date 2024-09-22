
import Foundation

enum Constants {
    static let accessKey = "wA174RjshDxdTQ0K6tcEGz9IRZko_PMwiwSPDp5ZCJA"
    static let secretKey = "deLLJ9DgAAabTTKD8WvHUp1js34Hk9NBmjqh1cfIr1U"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    
    static let authPath: String = "/oauth/token/"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
    static let unsplashURL = URL(string: "https://unsplash.com")!
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let authPath: String
    let defaultBaseURL: URL
    let unsplashURL: URL
    let authURLString: String

    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authPath: String, authURLString: String, defaultBaseURL: URL, unsplashURL: URL) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.authPath = authPath
        self.defaultBaseURL = defaultBaseURL
        self.unsplashURL = unsplashURL
        self.authURLString = authURLString
    }
    
    static var standard: AuthConfiguration {
            return AuthConfiguration(accessKey: Constants.accessKey,
                                     secretKey: Constants.secretKey,
                                     redirectURI: Constants.redirectURI,
                                     accessScope: Constants.accessScope,
                                     authPath: Constants.authPath,
                                     authURLString: Constants.unsplashAuthorizeURLString,
                                     defaultBaseURL: Constants.defaultBaseURL, 
                                     unsplashURL: Constants.unsplashURL)
        }
}
