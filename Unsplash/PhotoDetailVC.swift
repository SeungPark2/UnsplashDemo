//
//  PhotoDetailVC.swift
//  Kakaopay
//
//  Created by 박승태 on 2022/02/26.
//

import UIKit

protocol PhotoDetailDelegate: AnyObject {
    
    func photoDetailImageMove(with index: Int)
}

class PhotoDetailVC: UIViewController {
    
    weak var photoDetailDelegate: PhotoDetailDelegate?
    var selectedIndex: Int = 0
    var photos: [Photo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView?.minimumZoomScale = 1
        self.scrollView?.maximumZoomScale = 4
        
        self.photoImageView?.downloadedFrom(link: photos[selectedIndex].urls.regular)
        
        self.panGesture?.addTarget(self,
                                   action: #selector(panAction(_:)))
    }
    
    override func viewDidLayoutSubviews() {

        let heightRatio = UIScreen.main.bounds.width * (CGFloat(photos[selectedIndex].height ?? 0) / CGFloat(photos[selectedIndex].width ?? 1))

        self.photoImageViewHeight?.constant = heightRatio
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.currentIndex != self.selectedIndex {
            
            self.photoDetailDelegate?.photoDetailImageMove(with: self.currentIndex)
        }
    }
    
    @IBAction private func didTapClose(_ sender: UIButton) {
        
        self.dismiss(animated: true,
                     completion: nil)
    }
    
    @objc
    private func panAction(_ gesture: UIPanGestureRecognizer) {
        
        let position = gesture.velocity(in: self.view)
        
        if abs(position.x) > abs(position.y) {
            // 좌우 판단
            
            position.x < 0 ? print("left") :  print("right")
            return
        }
        
        if abs(position.y) > abs(position.x) {
            // 상하 판단
            
            position.y < 0 ? print("up") :  print("down")
        }
    }
    
    private var currentIndex: Int = 0
    
    @IBOutlet private weak var scrollView: UIScrollView?
    
    @IBOutlet private weak var photoImageView: UIImageView?
    
    @IBOutlet private weak var panGesture: UIPanGestureRecognizer?
    
    @IBOutlet private weak var photoImageViewY: NSLayoutConstraint?
    @IBOutlet private weak var photoImageViewHeight: NSLayoutConstraint?
}

extension PhotoDetailVC: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {

        return self.photoImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        self.photoImageViewY?.constant = -(5 * scrollView.zoomScale)
    }
}
