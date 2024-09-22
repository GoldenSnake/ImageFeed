
import Foundation

enum Constants {
    static let accessKey = "1yAaGD5zYSuwHjEmnuddEzKIoyQMdSvK_mjqh_c3xmA"
    static let secretKey = "M2utLw5Y89E93bVctaB8pREGaUVc0xW_Bv8CpT4GAfY"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    
    static let authPath: String = "/oauth/token/"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let authPath: String
    let defaultBaseURL: URL
    let authURLString: String

    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authPath: String, authURLString: String, defaultBaseURL: URL) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.authPath = authPath
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
    
    static var standard: AuthConfiguration {
            return AuthConfiguration(accessKey: Constants.accessKey,
                                     secretKey: Constants.secretKey,
                                     redirectURI: Constants.redirectURI,
                                     accessScope: Constants.accessScope,
                                     authPath: Constants.authPath,
                                     authURLString: Constants.unsplashAuthorizeURLString,
                                     defaultBaseURL: Constants.defaultBaseURL)
        }
}

//enum Constants {

//    static let accessScope = "public+read_user+write_likes"
//    static let authPath: String = "/oauth/token/"
//    static let defaultBaseURL = URL(string: "https://unsplash.com/")
//    static let apiURL = URL(string: "https://api.unsplash.com/")
//}
