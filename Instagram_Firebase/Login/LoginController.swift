//
//  LoginController.swift
//  Instagram_Firebase
//
//  Created by iosDev on 7/9/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LoginController: UIViewController {
    private let viewModel: LoginPageViewModel
    private let disposeBag = DisposeBag()
    
    init(viewModel: LoginPageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedText = NSMutableAttributedString(string: "Don't have an account?  ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        
        attributedText.append(NSAttributedString(string: "Sign Up.", attributes: [NSAttributedString.Key.foregroundColor: UIColor.rgb(red: 17, green: 154, blue: 237), NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)]))
        
        button.setAttributedTitle(attributedText, for: .normal)
//        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    }()
    
//    @objc fileprivate func handleShowSignUp() {
//        let signUpController = SignUpController()
//        self.navigationController?.navigationBar.barStyle = .default
//        navigationController?.pushViewController(signUpController, animated: true)
//    }
    
    private let logoContainerView: UIView = {
        let view = UIView()
        
        let logoImageView = UIImageView(image: UIImage.assetImage(AssetImagesNames.instagramLogoWhite))
        logoImageView.contentMode = .scaleAspectFit
        
        view.addSubview(logoImageView)
        logoImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 50)
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        view.backgroundColor = UIColor.rgb(red: 0, green: 120, blue: 175)
        return view
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 14)
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        //textField.isSecureTextEntry = true
        textField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 14)
        return textField
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 255)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    fileprivate func handleLoginButtonIsActive(isActive: Bool) {
        if isActive {
            loginButton.isEnabled = true
            loginButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        } else {
            loginButton.isEnabled = false
            loginButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        self.navigationController?.navigationBar.barStyle = .black
        
        view.backgroundColor = .white
        
        view.addSubview(logoContainerView)
        logoContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150)
        
        view.addSubview(dontHaveAccountButton)
        
        
        let guide = view.safeAreaLayoutGuide
        dontHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: guide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        setupInputFields()
        setupBindings()
    }
    
    private func setupInputFields() {
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton])
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        
        view.addSubview(stackView)
        
        stackView.anchor(top: logoContainerView.bottomAnchor, left: view.leftAnchor,
                         bottom: nil, right: view.rightAnchor, paddingTop: 40,
                         paddingLeft: 40, paddingBottom: 0, paddingRight: 40,
                         width: 0, height: 140)
    }
    
    private func setupBindings() {
        let email = emailTextField.rx.text
        let password = passwordTextField.rx.text
        let textFields = Observable.combineLatest(email, password).map { (email, password) -> UserInput in
            return UserInput(email: email, password: password)
        }
        _ = textFields.bind(to: viewModel.handleTextInputChange).disposed(by: disposeBag)
        
        Observable.combineLatest(textFields, loginButton.rx.tap).map { (userInput, _) -> UserInput in
            return userInput
            }.bind(to: viewModel.handleLogin).disposed(by: disposeBag)
        
        viewModel.loginButtonIsActive.subscribe(onNext: { [weak self] (isActive) in
            self?.handleLoginButtonIsActive(isActive: isActive)
        }).disposed(by: disposeBag)
        
        dontHaveAccountButton.rx.tap.bind(to: viewModel.signUp).disposed(by: disposeBag)
    }
}
