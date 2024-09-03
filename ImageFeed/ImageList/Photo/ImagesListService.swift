import UIKit

enum ImagesListServiceError: Error, LocalizedError {
    case failedToCreatePhotosRequest
    case failedToCreateURL
    case noAccessToken
        
    var errorDescription: String? {
        switch self {
        case .failedToCreatePhotosRequest:
            "Failed to create photos request"
        case .failedToCreateURL:
            "Failed to create URL for photo request"
        case .noAccessToken:
            "No access token"
        }
    }
}

final class ImagesListService {
    
    static let shared = ImagesListService()
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private (set) var photos: [Photo] = []
    
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    
    private let tokenStorage = OAuth2TokenStorage.shared
    
    private init() { }
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        
        guard task == nil else {
            return
        }
        
        guard let token = tokenStorage.token else {
            ErrorHandler.printError(ImagesListServiceError.noAccessToken,
                                    origin: "ImagesListService.fetchPhotosNextPage")
            return
        }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let request = makePhotosRequest(token: token, page: nextPage) else {
            ErrorHandler.printError(ImagesListServiceError.failedToCreatePhotosRequest,
                                    origin: "ImagesListService.fetchPhotosNextPage")
            return
        }
        
        task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            switch result {
            case .success(let photosResult):
                photosResult.forEach { self?.photos.append(Photo(photoResult: $0)) }
                NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
            case .failure(let error):
                ErrorHandler.printError(error, origin: "ImagesListService.fetchPhotosNextPage")
            }
            
            self?.lastLoadedPage = nextPage
            self?.task = nil
        }
        
        task?.resume()
    }
    
    private func makePhotosRequest(token: String, page: Int) -> URLRequest? {
        
       guard let apiURL = Constants.apiURL else {return nil}
        
        let url = apiURL.appendingPathComponent("photos")
        
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        urlComponents.queryItems = [URLQueryItem(name: "page", value: "\(page)")]
        
        guard let fullUrl = urlComponents.url else {
            let error = ImagesListServiceError.failedToCreateURL
            ErrorHandler.printError(error, origin: "ImagesListServise.makePhotosRequest")
            return nil }
        
        var request = URLRequest(url: fullUrl)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print("[lOG] [ProfileImageService.makeProfileImageRequest] - Profile Image Request: \(request)")
        return request
    }
}
