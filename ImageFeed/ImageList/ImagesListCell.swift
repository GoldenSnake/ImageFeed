import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    weak var delegate: ImagesListCellDelegate?
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImage.kf.cancelDownloadTask()
    }
    
    
    func setIsLiked(_ isLiked: Bool) {
          let buttonImage = UIImage(named: isLiked ? "like_button_on" : "like_button_off")
          likeButton.setImage(buttonImage, for: .normal)
      }
    
    @IBAction private func likeButtonClicked() {
       delegate?.imageListCellDidTapLike(self)
    }
}
