import XCTest

class Image_FeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    // Персональные данные
    private let email = ""
    private let password = ""
    private let nameAndLastName = ""
    private let username = ""

    
    // MARK: - Helpers
    private func typeTextWithDelay(_ text: String, textField: XCUIElement, characterDelay: TimeInterval = 0.1) {
        for character in text {
            textField.typeText(String(character))
            usleep(useconds_t(characterDelay * 1000000))
        }
    }
    
    private func tapDoneButton() {
        let doneButtonLabels = ["Готово", "Done"]
        for label in doneButtonLabels {
            let doneButton = app.toolbars.buttons[label]
            if doneButton.exists {
                doneButton.tap()
                return
            }
        }
        XCTFail("Neither 'Готово' nor 'Done' button was found.")
    }
    
    override func setUp() {
        super.setUp()
        
        let app = XCUIApplication()
        app.launchArguments.append("TestingMode")
        app.launch()
    }

    
    
    // MARK: - Tests
    
    func testAuth() throws {

        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 7))
        
        // User
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 10))
        
        loginTextField.tap()
        loginTextField.typeText(email)
        
        sleep(1)
        webView.swipeUp()
        tapDoneButton()
        
        // Password
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 10))
        
        passwordTextField.tap()
        sleep(1)
        typeTextWithDelay(password, textField: passwordTextField)
        
        sleep(1)
        tapDoneButton()
        
        // Login
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 1)
        sleep(1)
        XCTAssertTrue(cell.waitForExistence(timeout: 10))
    }
    
    func testFeed() throws {
        sleep(10)
        
        let cellToLike = app.tables.descendants(matching: .cell).element(boundBy: 1)
        
        cellToLike.buttons.firstMatch.tap()
        sleep(5)
        cellToLike.buttons.firstMatch.tap()
        sleep(5)
        
        cellToLike.tap()
        
        sleep(10)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        // Zoom in
        image.pinch(withScale: 3, velocity: 1) 
        // Zoom out
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButton = app.buttons["Backward"]
        navBackButton.tap()
        
        sleep(5)
        
        let cell = app.tables.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        sleep(1)
    }
    
    
    func testProfile() throws {
        sleep(5)
        
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        sleep(3)
        
        XCTAssertTrue(app.staticTexts[nameAndLastName].exists)
        XCTAssertTrue(app.staticTexts[username].exists)
        sleep(1)
        app.buttons["Logout"].tap()
        
        sleep(3)
        
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
        
        sleep(5)
    }
}
