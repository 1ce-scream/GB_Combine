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
        
        viewModel
            .$buttonText
            .dropFirst() // дропаем первое значение, заданное при инициализации
            .sink { value in
                XCTAssertEqual(value, expected)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel
            .$textTitle
            .dropFirst()
            .sink { value in
                XCTAssertEqual(value, expected2)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        viewModel.isGameStarted = false
        
        // Then
        wait(for: [expectation], timeout: 1)
    }
    
    func testButtonTextChanged() {
        // Given
        let expected = "Catch it!"
        let expectation = XCTestExpectation()
        
        viewModel
            .$buttonText
            .dropFirst(2)
            .sink { value in
                XCTAssertEqual(value, expected)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        viewModel.isGameStarted = true
        
        // Then
        wait(for: [expectation], timeout: 1)
    }
    
    func testWin() {
        // Given
        let expected = "You won!"
        let expectation = XCTestExpectation()
        
        viewModel
            .$textTitle
            .dropFirst()
            .sink { value in
                XCTAssertEqual(value, expected)
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
    }

    func testLoose() {
        // Given
        let expected = "You lose!"
        let expectation = XCTestExpectation()
        
        viewModel
            .$textTitle
            .dropFirst()
            .sink { value in
                XCTAssertEqual(value, expected)
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
    }
}
