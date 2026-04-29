//
//  SocialLocationsUITests.swift
//  SocialLocationsUITests
//
//  Created by Bernarda Perez De Nucci on 3/3/26.
//

import XCTest

final class SocialLocationsUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // IMPORTANT:
                // These require accessibility identifiers in LoginView

                let emailField = app.textFields["emailField"]
                let passwordField = app.secureTextFields["passwordField"]
                let loginButton = app.buttons["Log In"]

                XCTAssertTrue(emailField.exists)
                XCTAssertTrue(passwordField.exists)
                XCTAssertTrue(loginButton.exists)

                emailField.tap()
                emailField.typeText("test@test.com")

                passwordField.tap()
                passwordField.typeText("password123")

                loginButton.tap()

                // After login: Main TabView should appear
                let tabBar = app.tabBars.firstMatch
                XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
            }
    
    
    //TAB NAVIGATION TEST
    
        @MainActor
        func testTabNavigation() throws {
            let app = XCUIApplication()
            app.launch()

            let friendsTab = app.tabBars.buttons["Friends"]
            let profileTab = app.tabBars.buttons["Your Profile"]
            let mapTab = app.tabBars.buttons["Map"]

            XCTAssertTrue(friendsTab.exists)
            friendsTab.tap()

            XCTAssertTrue(profileTab.exists)
            profileTab.tap()

            XCTAssertTrue(mapTab.exists)
            mapTab.tap()
        }

    
    //FRIENDS SCREEN LOADS

        @MainActor
        func testFriendsScreenLoads() throws {
            let app = XCUIApplication()
            app.launch()

            app.tabBars.buttons["Friends"].tap()

            XCTAssertTrue(app.staticTexts["Friends"].exists)
        }

    
        //MAP SCREEN LOADS

        @MainActor
        func testMapScreenLoads() throws {
            let app = XCUIApplication()
            app.launch()

            app.tabBars.buttons["Map"].tap()

            // Check search bar exists
            let searchField = app.textFields["Search For A Location"]
            XCTAssertTrue(searchField.exists)
        }

    
        //PROFILE SCREEN LOADS

        @MainActor
        func testProfileScreenLoads() throws {
            let app = XCUIApplication()
            app.launch()

            app.tabBars.buttons["Your Profile"].tap()

            XCTAssertTrue(app.staticTexts["Your Profile"].exists)
            XCTAssertTrue(app.buttons["Edit Profile"].exists)
        }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
