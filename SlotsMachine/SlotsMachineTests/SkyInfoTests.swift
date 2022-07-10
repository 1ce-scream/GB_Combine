//
//  SkyInfoTests.swift
//  SlotsMachineTests
//
//  Created by Vitaliy Talalay on 10.07.2022.
//

import XCTest
import Combine
@testable import SlotsMachine

class SkyInfoTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()
    var viewModel: SkyInfoVM!
    
    override func setUpWithError() throws {
        super.setUp()
        
        viewModel = SkyInfoVM()
    }

    override func tearDownWithError() throws {
        cancellables.removeAll()
        viewModel = nil
        
        super.tearDown()
    }
    
    func testFetchSkyInfo() {
        // Given
        let startDate = "2022-06-17"
        let endDate = "2022-06-19"
        
        let expectation = expectation(description: "fetch test")
        var result: [SkyInfoModel] = []
       
        // When
        viewModel.fetchSkyInfo(startDate: startDate, endDate: endDate)

        viewModel.$skyInfoModels
            .receive(on: DispatchQueue.main)
            .sink{ value in
                result = value
            }
            .store(in: &cancellables)
        
        // Then
        XCTWaiter.wait(for: [expectation], timeout: 6)
        XCTAssertTrue(result.count > 0)
//        XCTAssertEqual(result.count, 3)
    }
    
    func testFetchSkyInfo2() {
        let startDate = "2022-06-17"
        let endDate = "2022-06-19"
        
        let expectation = expectation(description: "fetch test")
        
        viewModel.fetchSkyInfo(startDate: startDate, endDate: endDate)
        
        XCTWaiter.wait(for: [expectation], timeout: 6)
        XCTAssertTrue(viewModel.skyInfoModels.count > 0)
    }
}
