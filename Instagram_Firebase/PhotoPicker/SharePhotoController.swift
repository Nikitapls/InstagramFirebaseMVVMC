//
//  SharePhotoController.swift
//  Instagram_Firebase
//
//  Created by iosDev on 7/14/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import UIKit

class SharePhotoContoller: UIViewController {
    
    private let backendQueue = OperationQueue()
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .red
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let textView: UITextView = {
        let tf = UITextView()
        tf.font = UIFont.systemFont(ofSize: 14)
        return tf
    }()

    var selectedImage: UIImage? {
        didSet {
            imageView.image = selectedImage
        }
    }
    let savePostService: SavePostService = FirebaseService()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
  
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShareButton))
        
        setupImageAndTextViews()
    }

    @objc fileprivate func handleShareButton() {
        guard textView.text.count > 0 else { return }
        let savePostOperation = SavePostBackendOperation(image: selectedImage, postText: textView.text, creationDate: Date(), savePostService: savePostService)
        savePostOperation.completionBlock = { [weak self] in
            let result = savePostOperation.operationResult
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self?.navigationItem.rightBarButtonItem?.isEnabled = true
                    self?.dismiss(animated: true, completion: nil)
                }
            case .error(let error):
                DispatchQueue.main.async {
                    self?.showAlert(text: "Error loading post. error: \(error.debugDescription)")
                    self?.navigationItem.rightBarButtonItem?.isEnabled = true
                }
            }
        }
        
        backendQueue.addOperation(savePostOperation)
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    fileprivate func setupImageAndTextViews() {
        let containerView = UIView()
        containerView.backgroundColor = .white
        
        let guide = view.safeAreaLayoutGuide
        view.addSubview(containerView)
        containerView.anchor(top: guide.topAnchor, left: guide.leftAnchor, bottom: nil, right: guide.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100)
        
        containerView.addSubview(imageView)
        imageView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 0, width: 84, height: 0)
        
        containerView.addSubview(textView)
        textView.anchor(top: containerView.topAnchor, left: imageView.rightAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    private func showAlert(text: String) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alertController.message = text
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            alertController.dismiss(animated: true, completion: nil)
        }))
        present(alertController, animated: true)
    }
}
