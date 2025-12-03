//
//  TestCode_TutorialTests.swift
//  TestCode_TutorialTests
//
//  Created by 이병훈 on 12/3/25.
//

import XCTest
import RxSwift
@testable import TestCode_Tutorial

final class RxSwift_TutorialTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_distinctUntilChanged() {
        // Arrange
        let expect = expectation(description: "같은 이벤트 방출 금지")
        var results: [Int] = []
        let disposeBag = DisposeBag()

        let source = Observable.from([0, 0, 1, 1, 1, 2, 2, 3, 2, 2, 1])
            .distinctUntilChanged()
        
        // Act
        source.subscribe(onNext: { val in
            results.append(val)
        }, onCompleted: { expect.fulfill() })
        .disposed(by: disposeBag)
        
        wait(for: [expect], timeout: 1.0)
        
        // Assert
        XCTAssertEqual(results, [0, 1 ,2, 3, 2, 1])
    }

    func test_PublishSubject() throws {
        // Arrange
        let expect = expectation(description: "PublishSubject Completed")
        var results: [Int] = []
        let disposeBag = DisposeBag()
        
        let testSubject = PublishSubject<Int>()
        
        testSubject
            .subscribe(onNext: { value in
                results.append(value)
            }, onCompleted: { expect.fulfill() })
            .disposed(by: disposeBag)
        
        // Act
        testSubject.onNext(1)
        testSubject.onNext(2)
        testSubject.onCompleted()
        
        wait(for: [expect], timeout: 1.0)
        
        // Assert
        XCTAssertEqual(results, [1, 2])
    }

    func test_BehaviorSubject() throws {
        // Arrange
        let expect = expectation(description: "BehaviorSubject Completed")
        var results: [Int] = []
        let disposeBag = DisposeBag()
        
        let testSubject = BehaviorSubject<Int>(value: 3)
        
        testSubject
            .subscribe(onNext: { value in
                results.append(value)
            }, onCompleted: { expect.fulfill() })
            .disposed(by: disposeBag)
        
        // Act
        testSubject.onNext(1)
        testSubject.onNext(2)
        testSubject.onCompleted()
        
        wait(for: [expect], timeout: 1.0)
        
        // Assert
        XCTAssertEqual(results, [3, 1, 2])
    }

    // MARK: - Reduce Tutorial
    
    func test_짝수끼리총합WithReduce() {
        // Arrange
        let numbers = [1, 2, 3, 4, 5, 6]
        // Act
        let result = numbers.reduce(0) { acc, next in
            return next % 2 == 0 ? acc + next : acc
        }
        
        // Assert
        XCTAssertEqual(result, 12)
    }
    
    func test_같은초성끼리묶기WithReduce() {
        // Arrange
        let value = ["apple", "banana", "avocado", "blue"]

        var result: [String: [String]]
        
        // Act
        result = value.reduce([:]) { acc, next in
            var tempAcc = acc
            let key = String(next.first!).uppercased()
            tempAcc[key, default: []].append(next)
            return tempAcc
        }
        
        // Assert
        XCTAssertEqual(result, ["A": ["apple", "avocado"], "B": ["banana", "blue"]])
    }
    
    func test_reduceJsonSum() {
        // Arrange
        let items = [
            ["count": 1],
            ["count": 2],
            ["count": 3],
        ]
        // Act
        let result = items.reduce(0) { acc, next in
            acc + (next["count"] ?? 0)
        }
        // Assert
        XCTAssertEqual(result, 6)
    }
    
    func test_countCharactors() {
        // Arrange
        let chars = ["a", "b", "a", "c", "d", "c", "a"]
        // Act
        let counted = chars.reduce(into: [:]) { (acc: inout [String: Int], next) in
            acc[next, default: 0] += 1
        }
        // Assert
        XCTAssertEqual(counted, ["a": 3, "b": 1, "c": 2, "d": 1])
        
    }
    
    func test_merge() {
        // Arrange
        let obs1 = PublishSubject<Int>()
        let obs2 = PublishSubject<Int>()
        
        let disposeBag = DisposeBag()
        var result: [Int] = []
        // Act
        Observable.merge(obs1, obs2)
            .subscribe { result.append($0) }
            .disposed(by: disposeBag)
        
        obs1.onNext(1)
        obs2.onNext(2)
        obs1.onNext(1)
        obs2.onNext(2)
        // Assert
        XCTAssertEqual(result, [1, 2, 1, 2])
    }
    
    func test_flatMap() {
        // Arrange
        let disposeBag = DisposeBag()
        let trigger = PublishSubject<String>()
        var result: [String] = []
        
        let child = { (value: String) in
            Observable<String>.just("child-\(value)")
        }
        
        // Act
        trigger
            .flatMap { child($0) }
            .subscribe(onNext: { result.append($0) })
            .disposed(by: disposeBag)
        
        trigger.onNext("A")
        trigger.onNext("B")
        trigger.onNext("C")
        
        // Assert
        XCTAssertEqual(result, ["child-A", "child-B", "child-C"])
    }
    
    func test_flatMapLatest() {
        // Arrange
        let disposeBag = DisposeBag()
        let trigger = PublishSubject<String>()
        var result: [String] = []
        
        let child = { (value: String) in
            Observable<String>
                .just("child-\(value)")
                .delay(.milliseconds(100), scheduler: MainScheduler.instance)
        }
        
        // Act
        trigger
            .flatMapLatest { child($0) }
            .subscribe(onNext: { result.append($0) })
            .disposed(by: disposeBag)
        
        trigger.onNext("A")
        trigger.onNext("B")
        trigger.onNext("C")
        
        // Assert
        let expect = expectation(description: "flatMapLatest Done")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertEqual(result, ["child-C"])
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
    }
    
}
