//  Assemble
//  Created by David Spry on 22/6/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit
import Photos

struct MediaUtilities {
    
    /// Save the video located at the given URL to the photo library.
    /// - Parameter file: The URL of the video file to be saved.

    static public func saveToCameraRoll(_ file: URL) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: file)
        }, completionHandler: { didSave, error in
            if didSave { displayFileSavedConfirmation() }
            else if let error = error {
                print("[MediaUtilities] File could not be saved to photo library.\n\(error)")
            }
        })
    }
    
    /// Display a confirmation when a file has been saved to the photo library

    static private func displayFileSavedConfirmation() {
        /// <TODO>

        print("[MediaUtilities] File saved successfully")
    }
    
    /// Share the video file at the given URL as an Instagram Story using Instagram.
    /// - Parameter file: The URL of the video file to be shared.

    static public func shareToInstagram(_ file: URL) {
        guard let instagram = URL(string: "instagram-stories://share"),
              UIApplication.shared.canOpenURL(instagram)
              else { return }

        let data: Data
        do    { data = try Data(contentsOf: file) }
        catch { print("[MediaUtilities] Data could not be created from file URL."); return }

        let items: [String:Any] = ["com.instagram.sharedSticker.backgroundVideo" : data]
        UIPasteboard.general.setItems([items])
        UIApplication.shared.open(instagram)
    }
}
