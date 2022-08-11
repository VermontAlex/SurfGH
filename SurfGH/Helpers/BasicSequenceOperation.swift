//
//  OperationBase.swift
//  GitHub Viewer
//
//  Created by Oleksandr Oliinyk
//

import Foundation

protocol BasicSequenceOperationProtocol {
    associatedtype OperationState
    var state: OperationState { get set }
    var isReady: Bool { get }
    var isExecuting: Bool { get }
    var isFinished: Bool { get }
}

open class BasicSequenceOperation: Operation, BasicSequenceOperationProtocol {
    var task: URLSessionDataTask?
    
    var state: OperationState = .ready {
        willSet {
            self.willChangeValue(forKey: "isExecuting")
            self.willChangeValue(forKey: "isFinished")
        }
        
        didSet {
            self.didChangeValue(forKey: "isExecuting")
            self.didChangeValue(forKey: "isFinished")
        }
    }
    
    open override var isReady: Bool { return state == .ready }
    open override var isExecuting: Bool { return state == .executing }
    open override var isFinished: Bool { return state == .finished }
    
    enum OperationState: Int {
        case ready
        case executing
        case finished
    }
}
