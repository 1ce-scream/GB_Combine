//
//  SlotsMachineTests.swift
//  SlotsMachineTests
//
//  Created by Vitaliy Talalay on 10.07.2022.
//

import XCTest
import Combine
@testable import SlotsMachine


class SlotsMachineTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()
    var viewModel: SlotsMachineVM!
    
    override func setUp() {
        super.setUp()
        
        viewModel = SlotsMachineVM()
    }

    override func tearDown() {
        cancellables.removeAll()
        viewModel = nil
        
        super.tearDown()
    }

    func testButtonAndTitleTextsOnStart() {
        // Given
        let expected = "Start"
        let expected2 = "Let's play!"
        let expectation = XCTestExpectation()
        var result = ""
        var result2 = ""
        
        viewModel
            .$buttonText
            .dropFirst() // дропаем первое значение, заданное при инициализации
            .sink { value in
                result = value
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel
            .$textTitle
            .dropFirst()
            .sink { value in
                result2 = value
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        viewModel.isGameStarted = false
        
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(result, expected)
        XCTAssertEqual(result2, expected2)
    }
    
    func testButtonTextChanged() {
        // Given
        let expected = "Catch it!"
        let expectation = XCTestExpectation()
        var result = ""
        
        viewModel
            .$buttonText
            .dropFirst(2)
            .sink { value in
                result = value
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        viewModel.isGameStarted = true
        
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(result, expected)
    }
    
    func testWin() {
        // Given
        let expected = "You won!"
        let expectation = XCTestExpectation()
        var result = ""
        
        viewModel
            .$textTitle
            .dropFirst()
            .sink { value in
                result = value
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        viewModel.firstSlot = "🦠"
        viewModel.secondSlot = "🦠"
        viewModel.thirdSlot = "🦠"
        
        viewModel.isGameStarted = false
        viewModel.justForRemember = true
        
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(result, expected)
    }

    func testLoss() {
        // Given
        let expected = "You lose!"
        let expectation = XCTestExpectation()
        var result = ""
        
        viewModel
            .$textTitle
            .dropFirst()
            .sink { value in
                result = value
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        viewModel.firstSlot = "🥶"
        viewModel.secondSlot = "🤔"
        viewModel.thirdSlot = "😑"

        viewModel.isGameStarted = false
        viewModel.justForRemember = true
        
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(result, expected)
    }
}
