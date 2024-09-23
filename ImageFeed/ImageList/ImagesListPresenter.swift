
import UIKit

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var photos: [Photo] { get }
    var imagesListService: ImagesListService { get }
    func viewDidLoad()
    func getCellHeight(indexPath: IndexPath, tableView: UITableView) -> CGFloat
    func didTapLike(_ cell: ImagesListCell, tableView: UITableView)
    func didUpdatePhotos()
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    // MARK: - Public Properties
    
    weak var view: ImagesListViewControllerProtocol?
    var photos: [Photo] = []
    let imagesListService = ImagesListService.shared
    private var imagesListServiceObserver: NSObjectProtocol?
    
    // MARK: - Public Methods
    
    func viewDidLoad() {
           imagesListServiceObserver = NotificationCenter.default.addObserver(
               forName: ImagesListService.didChangeNotification,
               object: nil,
               queue: .main
           ) { [weak self] _ in
               guard let self = self else {return}
               self.didUpdatePhotos()
           }
           imagesListService.fetchPhotosNextPage()
       }
    
    func getCellHeight(indexPath: IndexPath, tableView: UITableView) -> CGFloat {
        let photo = imagesListService.photos[indexPath.row]
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        
        return cellHeight
    }
    
    func didTapLike(_ cell: ImagesListCell, tableView: UITableView) {
        
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self else { return }
            
            switch result {
            case .success:
                self.photos[indexPath.row].isLiked.toggle()
                cell.setIsLiked(self.photos[indexPath.row].isLiked)
            case .failure(let error):
                ErrorHandler.printError(error, origin: "ImagesListViewController.imageListCellDidTapLike")
                // alert
                let alert = UIAlertController(title: "Что-то пошло не так(",
                                              message: "Попробуйте ещё раз позже",
                                              preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default)
                alert.addAction(action)
                self.view?.showAlert(alert: alert)
            }
        }
        
    }
    
    func didUpdatePhotos() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            let indexPaths = (oldCount..<newCount).map { i in
                IndexPath(row: i, section: 0)
            }
            view?.updateTableViewAnimated(indexPaths)
        }
    }
    
}
