//
//  PhotoDetailVC.swift
//  Kakaopay
//
//  Created by 박승태 on 2022/02/26.
//

import UIKit

// MARK -- PhotoDetailDelegate

protocol PhotoDetailDelegate: AnyObject {
    
    func photoDetailImageMove(with index: Int)
}

class PhotoDetailVC: UIViewController {
    
    // MARK: -- Public Properties
    
    weak var photoDetailDelegate: PhotoDetailDelegate?
    var selectedIndex: Int = 0
    var photos: [Photo] = []
    
    // MARK: -- Public Method
    
    // MARK: -- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
                        
        self.view.bringSubviewToFront(self.navigationBar!)
        
        self.downSwipeGesture?.addTarget(self,
                                         action: #selector(self.didTapClose))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.photoCollectionView?.scrollToItem(
            at: IndexPath(row: self.selectedIndex,
                          section: 0),
            at: .centeredHorizontally,
            animated: false
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.currentIndex != self.selectedIndex {
            
            self.photoDetailDelegate?.photoDetailImageMove(with: self.currentIndex)
        }
    }
    
    // MARK: -- Private Method
    
    private func setNavigationBar() {
        
        self.navigationBar?
            .setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        
        self.navigationBar?
            .shadowImage = UIImage()
        
        self.navigationBar?.topItem?.title = self.photos[selectedIndex].user.name
    }
        
    @objc
    @IBAction private func didTapClose() {
        
        self.dismiss(animated: true,
                     completion: nil)
    }
    
    // MARK: -- Private Properties
    
    private var currentIndex: Int = 0
    
    // MARK: -- IBOutlet
    
    @IBOutlet private weak var navigationBar: UINavigationBar?
    
    @IBOutlet private weak var photoCollectionView: UICollectionView?
    
    @IBOutlet private weak var downSwipeGesture: UISwipeGestureRecognizer?
}

// MARK: -- UICollectionViewDelegate, UICollectionViewDataSource
// MARK: -- UICollectionViewDelegateFlowLayout

extension PhotoDetailVC: UICollectionViewDelegate,
                         UICollectionViewDataSource,
                         UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        return self.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoDetailCell.identifier,
                                                            for: indexPath) as? PhotoDetailCell,
              let photo = self.photos[safe: indexPath.row]
        else {
            
            return UICollectionViewCell()
        }
        
        cell.updateUI(with: photo)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width,
                      height: collectionView.frame.height - 1)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        guard let collectionView = self.photoCollectionView else { return }
        
        for cell in collectionView.visibleCells {
            
            let indexPath = collectionView.indexPath(for: cell)
            
            self.navigationBar?.topItem?.title = self.photos[indexPath?.row ?? selectedIndex].user.name
            self.currentIndex = indexPath?.row ?? self.selectedIndex
        }
    }
}
