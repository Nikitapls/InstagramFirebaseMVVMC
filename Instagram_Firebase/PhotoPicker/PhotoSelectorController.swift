//
//  File.swift
//  Instagram_Firebase
//
//  Created by iosDev on 7/11/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import UIKit
import Photos

class PhotoSelectorContoller: UICollectionViewController {
    
    private enum CellIds: String {
        case cellId
        case headerId
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        
        setupNavigationButtons()
        
        collectionView.register(PhotoSelectorCell.self, forCellWithReuseIdentifier: CellIds.cellId.rawValue)
        collectionView.register(PhotoSelectorHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CellIds.headerId.rawValue)
        
        fetchPhotos()
    }
    
    fileprivate var images = [UIImage]()
    fileprivate var assets = [PHAsset]()
    fileprivate var hightQualityImages = [Int: UIImage]()
    var selectedImage: UIImage?
    
    fileprivate func fetchPhotos() {
        let width = (view.frame.width - 3) / 4
        let fetchOptions = assetsFetchOptions()
        let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        DispatchQueue(label: "fetchImages").async { [weak self] in
            allPhotos.enumerateObjects { [weak self] (asset, count, stop) in
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: width, height: width)
                let options = PHImageRequestOptions()
                options.deliveryMode = .highQualityFormat
                options.isSynchronous = true
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { [weak self] (image, info) in
                    if let image = image {
                        self?.images.append(image)
                        self?.assets.append(asset)
                    }
                })
            }
            if self?.selectedImage == nil, self?.images.count ?? 0 > 0 {
                self?.selectedImage = self?.images[0]
            }
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
            }
        }
    }
    
    fileprivate func assetsFetchOptions() -> PHFetchOptions {
        let fetchOptions = PHFetchOptions()
        let fetchLimit = 10
        fetchOptions.fetchLimit = fetchLimit
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return fetchOptions
    }
    
    fileprivate func setupNavigationButtons() {
        navigationController?.navigationBar.tintColor = .black
        
        let cancelBarBarItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        let nextBarBarItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext))
        
        navigationItem.leftBarButtonItem = cancelBarBarItem
        navigationItem.rightBarButtonItem = nextBarBarItem
    }
    
    @objc fileprivate func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func handleNext() {
        let sharePhotoController = SharePhotoContoller()
        if let selectedImage = selectedImage,
            let index = images.firstIndex(of: selectedImage) {
            sharePhotoController.selectedImage = hightQualityImages[index]
        }
        navigationController?.pushViewController(sharePhotoController, animated: true)
    }
    
    // MARK: - CollectionViewControllerDelegate
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIds.cellId.rawValue, for: indexPath) as! PhotoSelectorCell
        cell.imageView.image = images[indexPath.item]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        
        return CGSize(width: width, height: width)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CellIds.headerId.rawValue, for: indexPath) as! PhotoSelectorHeader
        
        header.imageView.image = selectedImage
        
        guard let selectedImage = selectedImage,
            let index = images.firstIndex(of: selectedImage) else { return header }
        
        if let hightQualityImage = hightQualityImages[index] {
            header.imageView.image = hightQualityImage
            return header
        }
        
        let asset = assets[index]
        let image = hightResolutionImage(forAsset: asset)
        hightQualityImages[index] = image
        header.imageView.image = image
        return header
    }
    
    fileprivate func hightResolutionImage(forAsset asset: PHAsset?) -> UIImage? {
        guard let asset = asset else { return nil }
        let imageManager = PHImageManager.default()
        var outputImage: UIImage?
        
        let width = 600
        let targetSize = CGSize(width: width, height: width)
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = true
        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { (image, info) in
            outputImage = image
        })
        return outputImage
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedImage = images[indexPath.item]
        collectionView.reloadData()
        
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .bottom, animated: true)
    }
}

extension PhotoSelectorContoller: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 3) / 4
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}
