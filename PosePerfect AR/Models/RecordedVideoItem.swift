//
//  RecordedVideoItem.swift
//  PosePerfect AR
//
//  Created by Kaveh.Afroukhteh on 12/17/24.
//
import Foundation
import UIKit

struct RecordedVideoItem: Identifiable {
    let id = UUID()
    let videoURL: URL
    let jsonURL: URL?
    let thumbnail: UIImage
}
