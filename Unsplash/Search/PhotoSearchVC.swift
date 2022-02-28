//
//  PhotoSearchVC.swift
//  Unsplash
//
//  Created by 박승태 on 2022/02/27.
//

import Combine
import UIKit

class PhotoSearchVC: UIViewController {
    
    // MARK: -- Public Properties
    
    // MARK: -- Public Method
    
    // MARK: -- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
                            
        self.bindState(with: self.viewModel)
        self.setSearchBar()
        self.setCustomLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.searchBar?.searchTextField.textColor = .white
    }
    
    // MARK: -- Private Method
    
    private func setSearchBar() {
        
        self.searchBar?.enablesReturnKeyAutomatically = true
        
        self.searchBar?.tintColor = .white
        self.searchBar?.setValue("취소",
                                 forKey: "cancelButtonText")
    }
    
    private func setCustomLayout() {
        
        let layout = photoCollectionView?.collectionViewLayout as? CustomLayout
        layout?.delegate = self
        layout?.numberOfColums = 2
        
        self.photoCollectionView?.collectionViewLayout.invalidateLayout()
    }
    
    private func bindState(with viewModel: PhotoSearchVMProtocl) {
        
        viewModel.isLoaded
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                
                $0 ? self?.loadingIndicatorView?.stopAnimating() :
                     self?.loadingIndicatorView?.startAnimating()
                self?.loadingIndicatorView?.isHidden = $0
                
                if $0 { self?.photoCollectionView?.reloadData() }
            }
            .store(in: &self.cancellable)
        
        viewModel.errMsg
            .filter { $0 != "" }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                
                self?.showAlert(content: $0)
            }
            .store(in: &self.cancellable)
        
        viewModel.isEmptyPhotos
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                
                self?.resultEmptyLabel?.isHidden = !$0
            }
            .store(in: &self.cancellable)
    }
    
    // MARK: -- Private Properties
    
    private let viewModel: PhotoSearchVMProtocl = PhotoSearchVM()
    private var cancellable = Set<AnyCancellable>()
    
    // MARK: -- IBOutlet
    
    @IBOutlet private weak var searchBar: UISearchBar?
    
    @IBOutlet private weak var photoCollectionView: UICollectionView?
    @IBOutlet private weak var resultEmptyLabel: UILabel?
    
    @IBOutlet private weak var loadingIndicatorView: UIActivityIndicatorView?
}

// MARK: -- UICollectionViewDelegate, UICollectionViewDataSource
// MARK: -- UICollectionViewDelegateFlowLayout, CustomLayoutDelegate

extension PhotoSearchVC: UICollectionViewDelegate,
                         UICollectionViewDataSource,
                         UICollectionViewDelegateFlowLayout,
                         CustomLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        return self.viewModel.resultPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoSearchCell.identifier,
                                                            for: indexPath) as? PhotoSearchCell,
              let photo = self.viewModel.resultPhotos[safe: indexPath.row]
        else {
                        
            return UICollectionViewCell()
        }
        
        cell.updateUI(with: photo)
        
        return cell
    }
    
    func collectionView(collectionVIew: UICollectionView,
                        heightForItemAtIndexPath indexPath: IndexPath) -> CGFloat {

        guard let photoWidth = self.viewModel.resultPhotos[safe: indexPath.row]?.width,
              let photoHeight = self.viewModel.resultPhotos[safe: indexPath.row]?.height
        else {

            return self.view.frame.width / 2
        }

        return (self.view.frame.width / 2) * (CGFloat(photoHeight) / CGFloat(photoWidth))
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        if let photoDetailVC = storyboard?.instantiateViewController(withIdentifier: "PhotoDetailVC") as? PhotoDetailVC {
            
            photoDetailVC.selectedIndex = indexPath.row
            photoDetailVC.photos = self.viewModel.resultPhotos
            photoDetailVC.photoDetailDelegate = self
            
            photoDetailVC.modalPresentationStyle = .fullScreen
            
            self.present(photoDetailVC,
                         animated: true,
                         completion: nil)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                  willDecelerate decelerate: Bool) {
        
        let transtionY: CGFloat = scrollView.panGestureRecognizer.translation(in: self.view).y
        
        if transtionY != 0 &&
           self.searchBar?.searchTextField.text != "" &&
           !(self.searchBar?.searchTextField.isEditing ?? true) {
            
            self.tabBarController?.setTabBarHidden(
                transtionY < -15,
                animated: true
            )
        }
        
        if scrollView.contentOffset.y > 0,
           (scrollView.contentOffset.y + scrollView.frame.size.height) >
           scrollView.contentSize.height - 25 {
            
            self.viewModel.requestPhotos()
        }
    }
}

// MARK: -- UISearchBarDelegate

extension PhotoSearchVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String) {
        
        self.viewModel.typing(with: searchText)
        self.resultEmptyLabel?.isHidden = true
        self.tabBarController?.setTabBarHidden(false,
                                               animated: true)
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
    
        searchBar.setShowsCancelButton(true,
                                       animated: true)
        return true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        searchBar.setShowsCancelButton(false,
                                       animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.text = ""
        searchBar.endEditing(true)
        self.tabBarController?.setTabBarHidden(false,
                                               animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.endEditing(true)
        self.photoCollectionView?.setContentOffset(.zero,
                                                   animated: true)
        self.viewModel.requestPhotos()
    }
}

// MARK: -- PhotoDetailDelegate

extension PhotoSearchVC: PhotoDetailDelegate {
    
    func photoDetailImageMove(with index: Int) {
        
        self.photoCollectionView?.scrollToItem(at: IndexPath(row: index,
                                                             section: 0),
                                               at: .top,
                                               animated: false)
    }
}
