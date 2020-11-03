//
//  ImageSaver.swift
//  Instagram_Firebase
//
//  Created by iosDev on 10/15/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import UIKit.UIImage

class ImageSaver {
    static func save(image: UIImage?) -> String? {
        guard let image = image,
            let data = image.pngData() else { return nil }
        let filename = UUID().uuidString
        do {
            try data.write(to: getDocumentsDirectory().appendingPathComponent(filename))
        } catch let error {
            print(error)
            return nil
        }
        return filename
    }
    
    static private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    static func extract(path: String?) -> UIImage? {
        guard let path = path else { return nil }
        let url = getDocumentsDirectory().appendingPathComponent(path)
        do {
            let data = try Data(contentsOf: url)
            return UIImage(data: data)
        } catch let error {
            print(error)
            return nil
        }
    }
    
    static func remove(from path: String?) {
        guard let path = path else { return }
        let url = getDocumentsDirectory().appendingPathComponent(path)
        do {
            try FileManager.default.removeItem(at: url)
        } catch let error {
            print(error)
        }
    }
}
