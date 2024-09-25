@testable import ImageFeed
import XCTest

final class ProfileViewTests: XCTestCase {
    func testViewControllerCallsPresenter() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testUpdateProfile() {
        //given
        let username = "test user name"
        let name = "test name"
        let loginName = "test login name"
        let bio = "test bio"
        let profile = Profile(username: username, name: name, loginName: loginName, bio: bio)
        
        let profileService = ProfileServiceMock(profile: profile)
        
        let viewController = ProfileViewController()
        let presenter = ProfilePresenter(profileService: profileService)
        viewController.presenter = presenter
        presenter.view = viewController
        
        guard let nameLabel = viewController.nameLabel else {return}
        guard let loginLabel = viewController.loginLabel else {return}
        guard let descriptionLabel = viewController.descriptionLabel else {return}
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertEqual(nameLabel.text, name)
        XCTAssertEqual(loginLabel.text, loginName)
        XCTAssertEqual(descriptionLabel.text, bio)
    }
    
    func testUpdateAvatarOnLoading() {
        let imageService = ProfileImageServiceMock(avatarURL: "https://api.unsplash.com")
        
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter(profileImageService: imageService)
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertTrue(viewController.avatarUpdated)
    }
    
    func testUpdateAvatarDelayed() {
        let imageService = ProfileImageServiceMock()
        
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter(profileImageService: imageService)
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertFalse(viewController.avatarUpdated)
        
        imageService.avatarURL = "https://api.unsplash.com"
        NotificationCenter.default.post(name: ProfileImageService.didChangeNotification, object: self)
        
        XCTAssertTrue(viewController.avatarUpdated)
    }
    
    func testShowAlert() {
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.logout()
        
        //then
        XCTAssertTrue(viewController.alertPresented)
        XCTAssertEqual(viewController.alert?.title, "Пока, пока!")
    }
}
