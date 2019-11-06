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
import FloatingPanel
import WebKit


class HomeVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let apiClient = APIClient()
    
    let videosRy: BehaviorRelay<[Video]> = BehaviorRelay(value: [])
    var disposeBag = DisposeBag()
    
    var fpc: FloatingPanelController!
    var webView: WKWebView!
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = self.view.center // Also show the indicator even when the animation is stopped.
        activityIndicator.hidesWhenStopped = false
        if #available(iOS 13.0, *) {
            activityIndicator.style = UIActivityIndicatorView.Style.large
        } else {
            // Fallback on earlier versions
        } // Start animation.
        activityIndicator.startAnimating()
        return activityIndicator
        
    }()

    
    
    @IBOutlet weak var segment: UISegmentedControl!
    
    //var videosOb: Observable<[Video]> = Observable.empty()

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            refreshVideos(query: "get_random")
            break
        case 1:
            refreshVideos(query: "sort_comment")
            break
        case 2:
            refreshVideos(query: "sort_like")
            break
        case 3:
            refreshVideos(query: "sort_view")
            break
        default: break
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initFloatingPanel()
        refreshVideos(query: "")
        bindTableView()
        
        self.view.addSubview(self.activityIndicator)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        fpc.removePanelFromParent(animated: true)
    }
    
    private func initFloatingPanel() {
        fpc = FloatingPanelController()
        fpc.delegate = self // Optional
        
        let contentVC = UIViewController()//SFSafariViewController(url: URL(string: "https://google.com")! )
        
        //WebView::
        webView = WKWebView(frame: CGRect.zero)
        webView.translatesAutoresizingMaskIntoConstraints = false
        contentVC.view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.leftAnchor.constraint(equalTo: contentVC.view.safeAreaLayoutGuide.leftAnchor),
            webView.rightAnchor.constraint(equalTo: contentVC.view.safeAreaLayoutGuide.rightAnchor),
            webView.topAnchor.constraint(equalTo: contentVC.view.safeAreaLayoutGuide.topAnchor,constant: 32),
            webView.bottomAnchor.constraint(equalTo: contentVC.view.safeAreaLayoutGuide.bottomAnchor)
            ])
        webView.load(URLRequest(url: URL(string: "https://youtube.com")!))
        webView.navigationDelegate = self
        //WebView::
        
        
        fpc.set(contentViewController: contentVC)
        fpc.track(scrollView: webView.scrollView)
        
        
        fpc.surfaceView.cornerRadius = 24.0
        
        fpc.addPanel(toParent: self)
    }
    
    private func refreshVideos(query: String) {
        activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
        apiClient.get(path: "/api/videos/"+query, object: [Video()]) { (result) in
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
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
        
        tableView.rx.modelSelected(Video.self)
            //.map { $0.embedHtml ?? "" }
            .map { URL(string:"https://www.youtube.com/watch?v=\($0.youtubeId ?? "")")! }
            .subscribe(onNext: { [weak self] url in
                //self?.webView.loadHTMLString(html, baseURL: nil)
                self?.webView.load(URLRequest(url: url))
            })
//            .map { URL(string:"https://www.youtube.com/watch?v=\($0.youtubeId ?? "")")! }
//            .map { SFSafariViewController(url: $0) }
//            .subscribe(onNext: { [weak self] safariViewController in
//                self?.present(safariViewController, animated: true)
//            })
            .disposed(by: disposeBag)
        
    }
    
    
}

extension HomeVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        if (webView.url?.valueOf("v") != nil) {
            self.fpc.move(to: .half, animated: true)
            self.fpc.surfaceView.backgroundColor = UIColor(red:0.13, green:0.13, blue:0.13, alpha:1.0)
        } else {
            
            self.fpc.surfaceView.backgroundColor = UIColor.white
        }
    }
}

extension HomeVC: FloatingPanelControllerDelegate {
    
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        return MyFloatingPanelLayout()
    }
}



class MyFloatingPanelLayout: FloatingPanelLayout {
    var initialPosition: FloatingPanelPosition {
        return .tip
    }
    var topInteractionBuffer: CGFloat { return 0.0 }
    var bottomInteractionBuffer: CGFloat { return 0.0 }
    func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .full: return 0
        case .half: return 340.0
        case .tip: return 80.0 // Visible + ToolView
        default: return nil
        }
    }
}


