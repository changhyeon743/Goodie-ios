//
//  ViewController.swift
//  Goodie
//
//  Created by 이창현 on 21/09/2019.
//  Copyright © 2019 이창현. All rights reserved.
//

import UIKit
import SDWebImage
import RxSwift
import RxCocoa
import SafariServices

class HomeVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let apiClient = APIClient()
    
    let videosRy: BehaviorRelay<[Video]> = BehaviorRelay(value: [])
    var disposeBag = DisposeBag()
    
    
    
    //var videosOb: Observable<[Video]> = Observable.empty()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        refreshVideos()
        bindTableView()
    }
    
    private func refreshVideos() {
        apiClient.get(path: "/api/v1/videos/", object: [Video()]) { (result) in
            switch result {
            case .success(let datas):
                self.videosRy.accept(datas)
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }

    private func bindTableView() {
        let nibName = UINib(nibName: "MainTableViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "cell")
        
        videosRy.bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: MainTableViewCell.self)) { (index: Int, element: Video, cell: MainTableViewCell) in
                cell.titleLabel.text = element.title
            cell.detailLabel.text = "\(element.publisher ?? "")  . 조회수 \(element.viewCount ?? 0)회 "
                //cell.profileImageView.image = UIImage(named: "profile")
            cell.thumbnailImageView?.sd_setImage(with: URL(string: element.thumbnail ?? ""), placeholderImage: UIImage(named: "thumbnail"), options: .continueInBackground, completed: nil)
                //cell.thumbnailImageView.sd_setImage(with: element.thumbnail, completed: nil)
            }.disposed(by: disposeBag)
        
//        tableView.rx.itemSelected.subscribe({ (indexPath) in
//            print(indexPath.debugDescription)
//        }).disposed(by: disposeBag)
        tableView.rx.modelSelected(Video.self)
//            .map{$0.youtubeId ?? ""}
//            .subscribe ( onNext: {[weak self] id in
//                self?.youtubePlayerView.loadVideoID(id)
//
//            })
            .map { URL(string:"https://www.youtube.com/watch?v=\($0.youtubeId ?? "")")! }
            .map { SFSafariViewController(url: $0) }
            .subscribe(onNext: { [weak self] safariViewController in
                self?.present(safariViewController, animated: true)
            })
            .disposed(by: disposeBag)
        
    }
    
    
    
}
