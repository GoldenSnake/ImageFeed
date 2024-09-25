import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    weak var delegate: ImagesListCellDelegate?
    
    @IBOutlet private var cellImage: UIImageView!
    @IBOutlet private var likeButton: UIButton!
    @IBOutlet private var dateLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImage.kf.cancelDownloadTask()
    }
    
    // MARK: - Public Method
    
    func setIsLiked(_ isLiked: Bool) {
        
        let buttonImage = UIImage(named: isLiked ? "like_button_on" : "like_button_off")
        likeButton.setImage(buttonImage, for: .normal)
    }
    
    public func configCell(imageUrl: URL?, isLiked: Bool, date: String) {
        
        cellImage.kf.indicatorType = .activity
        cellImage.kf.setImage(with: imageUrl, placeholder: UIImage(named: "placeholder"))
        
        dateLabel.text = date
        
        setIsLiked(isLiked)
    }
    
    @IBAction private func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
        print("[lOG] [ImagesListCell] - Tap Like button")
    }
}
