import UIKit

enum ImagesListServiceError: Error, LocalizedError {
    case failedToCreatePhotosRequest
    case failedToCreateURL
    case noAccessToken
    case failedToCreateLikeRequest
    
    var errorDescription: String? {
        switch self {
        case .failedToCreatePhotosRequest:
            "Failed to create photos request"
        case .failedToCreateURL:
            "Failed to create URL for photo request"
        case .noAccessToken:
            "No access token"
        case .failedToCreateLikeRequest:
            "Failed to create like request"
        }
    }
}

final class ImagesListService {
    
    static let shared = ImagesListService()
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private (set) var photos: [Photo] = []
    
    private var lastLoadedPage: Int?
    private var photosTask: URLSessionTask?
    private var likeTask: URLSessionTask?
    
    private let tokenStorage = OAuth2TokenStorage.shared
    
    private init() { }
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        
        guard photosTask == nil else {
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
        
        photosTask = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            switch result {
            case .success(let photosResult):
                photosResult.forEach { self?.photos.append(Photo(photoResult: $0)) }
                NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
            case .failure(let error):
                ErrorHandler.printError(error, origin: "ImagesListService.fetchPhotosNextPage")
            }
            
            self?.lastLoadedPage = nextPage
            self?.photosTask = nil
        }
        
        photosTask?.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard likeTask == nil else {
            return
        }
        
        guard let token = tokenStorage.token else {
            ErrorHandler.printError(ImagesListServiceError.noAccessToken,
                                    origin: "ImagesListService.changeLike")
            return
        }
        
        guard let request = makeLikeRequest(token: token, photoId: photoId, isLike: isLike) else {
            ErrorHandler.printError(ImagesListServiceError.failedToCreateLikeRequest,
                                    origin: "ImagesListService.changeLike")
            return
        }
        
        
        likeTask = URLSession.shared.dataMainQueue(for: request) { [weak self] (result: Result<Data, Error>) in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
            
            self?.likeTask = nil
        }
        likeTask?.resume()
    }
    
    func clearData() {
        photos = []
        lastLoadedPage = nil
        photosTask?.cancel()
        photosTask = nil
        likeTask?.cancel()
        likeTask = nil
    }
    
    private func makePhotosRequest(token: String, page: Int) -> URLRequest? {
        
        let apiURL = Constants.defaultBaseURL
        
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
        print("[lOG] [ImagesListService.makePhotosRequest] - Images Request: \(request)")
        return request
    }
    
    private func makeLikeRequest(token: String, photoId: String, isLike: Bool) -> URLRequest? {
        
        let apiURL = Constants.defaultBaseURL 
        
        let url = apiURL
            .appendingPathComponent("photos")
            .appendingPathComponent(photoId)
            .appendingPathComponent("like")
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print("[lOG] [ImagesListService.makeLikeRequest] - Like Request: \(request)")
        return request
    }
}
