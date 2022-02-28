//
//  PhotoListVC.swift
//  Kakaopay
//
//  Created by 박승태 on 2022/02/25.
//

import Combine
import UIKit

class PhotoListVC: UIViewController {

    // MARK: -- Public Properties
    
    // MARK: -- Public Method
    
    // MARK: -- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.bindState(with: self.viewModel)
        self.setNavigationBar()
    }
    
    private func setNavigationBar() {
        
        self.navigationController?
            .navigationBar
            .setBackgroundImage(UIImage(),
                                for: UIBarMetrics.default)
        self.navigationController?
            .navigationBar
            .shadowImage = UIImage()
    }
    
    // MARK: -- Private Method
    
    private func bindState(with viewModel: PhotoListVMProtocol) {
        
        viewModel.isLoaded
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                
                $0 ? self?.loadingIndicatorView?.stopAnimating() :
                     self?.loadingIndicatorView?.startAnimating()
                self?.loadingIndicatorView?.isHidden = $0
                
                if $0 { self?.photoTableView?.reloadData() }
            }
            .store(in: &self.cancellable)
        
        viewModel.errMsg
            .filter { $0 != "" }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                
                self?.showAlert(content: $0)
            }
            .store(in: &self.cancellable)
    }
    
    // MARK: -- Private Properties
    
    private let viewModel: PhotoListVMProtocol = PhotoListVM()
    private var cancellable = Set<AnyCancellable>()
    private let refreshControl = UIRefreshControl()
    
    // MARK: -- IBOutlet
    
    @IBOutlet private weak var photoTableView: UITableView?
    
    @IBOutlet private weak var loadingIndicatorView: UIActivityIndicatorView?
}

// MARK: -- UITableViewDelegate, UITableViewDataSource

extension PhotoListVC: UITableViewDelegate,
                       UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        
        return self.viewModel.photos.count
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let photoWidth = self.viewModel.photos[safe: indexPath.row]?.width,
              let photoHeight = self.viewModel.photos[safe: indexPath.row]?.height
        else {
                  
            return 200
        }
        
        return self.view.frame.width * (CGFloat(photoHeight) / CGFloat(photoWidth))
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PhotoCell.identifier,
                                                       for: indexPath) as? PhotoCell,
              let photo = self.viewModel.photos[safe: indexPath.row]
        else {
            
            return UITableViewCell()
        }
        
        cell.updateUI(with: photo)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        if let photoDetailVC = storyboard?.instantiateViewController(withIdentifier: "PhotoDetailVC") as? PhotoDetailVC {
            
            photoDetailVC.selectedIndex = indexPath.row
            photoDetailVC.photos = self.viewModel.photos
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
        
        if transtionY != 0 {
            
            self.navigationController?.setNavigationBarHidden(
                transtionY < -15,
                animated: true
            )
            
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

// MARK: -- PhotoDetailDelegate

extension PhotoListVC: PhotoDetailDelegate {
    
    func photoDetailImageMove(with index: Int) {
        
        self.photoTableView?.scrollToRow(at: IndexPath(row: index,
                                                       section: 0),
                                         at: .middle,
                                         animated: false)
    }
}
