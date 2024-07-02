//
//  Constants.swift
//  ImageFeed
//
import Foundation

enum Constants {
//    static let accessKey = "wA174RjshDxdTQ0K6tcEGz9IRZko_PMwiwSPDp5ZCJA"
    static let accessKey = "102wblY3fP424rehnzyT-IpWlgIej_0CQivT5tnCAqk"
    
//    static let secretKey = "deLLJ9DgAAabTTKD8WvHUp1js34Hk9NBmjqh1cfIr1U"
    static let secretKey = "XfSThFf4EPaHFGC3s9wDxEHxiDymOz56Hh7wEmkOD4c"
    
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let authPath: String = "/oauth/token/"
    static let defaultBaseURL = URL(string: "https://unsplash.com/")
    static let apiURL = URL(string: "https://api.unsplash.com/")
}
