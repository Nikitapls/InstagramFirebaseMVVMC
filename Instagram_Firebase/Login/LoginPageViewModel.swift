//
//  LoginPageViewModel.swift
//  Instagram_Firebase
//
//  Created by iosDev on 10/1/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol LoginPageViewModelProtocol {
    var handleTextInputChange: PublishRelay<UserInput> { get }
    var handleLogin: PublishRelay<UserInput> { get }
    var signUp: PublishRelay<Void> { get }
    // Outputs
    var loginButtonIsActiveObservable: Observable<Bool> { get }
}

class LoginPageViewModel {
    private let disposeBag = DisposeBag()
    
    private let signInService: SignInService = FirebaseService()
    private let coordinator: LoginPageCoordinatorProtocol
    // Inputs
    let handleTextInputChange = PublishRelay<UserInput>()
    let handleLogin = PublishRelay<UserInput>()
    let signUp = PublishRelay<Void>()
    // Outputs
    let loginButtonIsActive = BehaviorRelay<Bool>(value: false)
    
    
    init(coordinator: LoginPageCoordinator) {
        self.coordinator = coordinator
        
        setupBindings()
    }
    
    private func setupBindings() {
        handleTextInputChange.subscribe(onNext: { [weak self] (userInput) in
            let isFormValid = userInput.email?.count ?? 0 > 0 && userInput.password?.count ?? 0 > 0
            self?.loginButtonIsActive.accept(isFormValid)
        }).disposed(by: disposeBag)
        
        handleLogin.subscribe(onNext: { [weak self] (userInput) in
            guard let password = userInput.password,
                let email = userInput.email else { return }
            
            self?.signInService.signIn(email: email, password: password) { (success) in
                if success {
                    self?.coordinator.coordinateToMainTabBarCoordinator()
                }
            }
        }).disposed(by: disposeBag)
        
        signUp.subscribe(onNext: { [weak self] () in
            self?.coordinator.showSignUpController()
            }).disposed(by: disposeBag)
    }
}

extension LoginPageViewModel: LoginPageViewModelProtocol {
    var loginButtonIsActiveObservable: Observable<Bool> {
        return loginButtonIsActive.asObservable()
    }
    
    
}
