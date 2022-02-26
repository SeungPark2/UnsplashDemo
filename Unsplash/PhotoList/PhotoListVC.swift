//
//  PhotoListVC.swift
//  Kakaopay
//
//  Created by 박승태 on 2022/02/25.
//

import Combine
import UIKit

class PhotoListVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.bindState(with: self.viewModel)
        
        viewModel.requestPhotos()
        
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    private func bindState(with viewModel: PhotoListVMProtocol) {
        
        viewModel.isLoaded
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                
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
    
    private let viewModel: PhotoListVMProtocol = PhotoListVM()
    private var cancellable = Set<AnyCancellable>()
    
    @IBOutlet private weak var photoTableView: UITableView?
}

extension PhotoListVC: UITableViewDelegate,
                       UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        
        return self.viewModel.photos.count
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let width = self.viewModel.photos[safe: indexPath.row]?.width,
              let height = self.viewModel.photos[safe: indexPath.row]?.height else {
                  
            return 200
        }
        
        return self.view.frame.width * (CGFloat(height) / CGFloat(width))
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PhotoCell.identifier,
                                                       for: indexPath) as? PhotoCell,
              let photo = self.viewModel.photos[safe: indexPath.row] else {
            
            return UITableViewCell()
        }
        
        cell.updateUI(with: photo)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        if let photoDetailVC = storyboard?.instantiateViewController(withIdentifier: "PhotoDetailVC") as? PhotoDetailVC {
            
            photoDetailVC.selectedIndex = indexPath.row
            photoDetailVC.photos = viewModel.photos
            
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

extension PhotoListVC: PhotoDetailDelegate {
    
    func photoDetailImageMove(with index: Int) {
        
        self.photoTableView?.scrollToRow(at: IndexPath(row: index,
                                                       section: 0),
                                         at: .top,
                                         animated: false)
    }
}
