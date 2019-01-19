//
//  ViewController.swift
//  UnevenPagination
//
//  Created by Ahmed Khalaf on 1/18/19.
//  Copyright © 2019 Ahmed Khalaf. All rights reserved.
//

import UIKit

let data: [Int] = Array(1...300)
let colors = Array(repeating: [UIColor.red, .green, .blue], count: data.count).flatMap({ $0 })

let spacing: CGFloat = 50

class ViewController: UIViewController {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var lastTargetContentOffsetX: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        collectionView.decelerationRate = .fast
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionView.performBatchUpdates(nil, completion: nil)
    }

}

class PairItemView: UIView {
    @IBOutlet var label: UILabel!
}

class Cell: UICollectionViewCell {
    var index = 0 {
        didSet {
            leftView.label.text = "\(index * 2 - 1)"
            rightView.label.text = "\(index * 2)"
            
            leftView.backgroundColor = colors[index - 1]
            rightView.backgroundColor = colors[index - 1]
        }
    }
    
    @IBOutlet private var leftView: PairItemView!
    @IBOutlet private var rightView: PairItemView!
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! Cell
        cell.index = data[indexPath.row]
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width * 2, height: collectionView.bounds.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: spacing / 2, bottom: 0, right: spacing / 2)
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let targetMidScreenX = targetContentOffset.pointee.x + collectionView.bounds.size.width / 2
        let pairWidth = collectionView.bounds.size.width * 2 + spacing
        
        let pairIndex = CGFloat(Int(targetMidScreenX / pairWidth))
        
        let itemWidth = (pairWidth - spacing) / 2
        let leftItemX = pairIndex * pairWidth + spacing / 2
        let rightItemX = leftItemX + itemWidth
        
        let leftItemMidX = leftItemX + itemWidth / 2
        let rightItemMidX = leftItemMidX + itemWidth
        
        if abs(targetMidScreenX - leftItemMidX) < abs(targetMidScreenX - rightItemMidX) {
            targetContentOffset.pointee.x = leftItemX
        } else {
            targetContentOffset.pointee.x = rightItemX
        }
        
        // To fix choppiness on small quick swipes
        if velocity.x != 0 && lastTargetContentOffsetX == targetContentOffset.pointee.x {
            scrollView.setContentOffset(targetContentOffset.pointee, animated: true)
        }
        
        lastTargetContentOffsetX = targetContentOffset.pointee.x
    }
}

extension CGFloat {
    func clamped(minValue: CGFloat, maxValue: CGFloat) -> CGFloat {
        return Swift.min(maxValue, Swift.max(minValue, self))
    }
}
