//
//  FullImageViewController.swift
//  QuestRentaTeam
//
//  Created by Евгений Бейнар on 11/06/2019.
//  Copyright © 2019 zuk. All rights reserved.
//

import UIKit
import AlamofireImage
import MBProgressHUD

final class FullImageViewController: UIViewController {
    
//MARK: - Variable
    var wallpaper: Wallpaper?
    let downloader = ImageDownloader()
    var visibilityState: Bool = false //status bar invis
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
//MARK: - IB O
    @IBOutlet var fullImgView: UIImageView!
    @IBOutlet var fullImgScrollView: UIScrollView!
    
//MARK: - life C
    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadImage()
        
        fullImgScrollView.backgroundColor = UIColor.white
        fullImgScrollView.delegate = self
        setZoomParametersForSize(fullImgScrollView.bounds.size)
        fullImgScrollView.zoomScale = fullImgScrollView.minimumZoomScale
        recenterImage()
        
        setupGesturesRecognizers()
    }
    
    //status bar invis
    override var prefersStatusBarHidden: Bool {
        return visibilityState
    }
    
//MARK: - private func
    private func setupDate() {
        let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 44.0))
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.center
        label.text = "Date of download\n\(getDate())"
        self.navigationItem.titleView = label
    }
    
    private func getDate() -> String {
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .long
        return formatter.string(from: currentDate)
    }
    
    private func downloadImage() {
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .indeterminate
        hud.label.text = "Loading ..."
        
        let urlRequest = URLRequest(url: URL(string: wallpaper!.urlImage)!)
        downloader.download(urlRequest) { response in
            
            guard let loadedImage: UIImage = response.result.value else {
                self.showErrorAlertMessage(title: "error", message: "error")
                self.fullImgView.image = #imageLiteral(resourceName: "placeholder")
                hud.hide(animated: true)
                return
            }
            
            self.fullImgView.image = loadedImage
            self.setupDate()
            hud.hide(animated: true)
        }
    }
    
//MARK: - gesture recognizer
    private func setupGesturesRecognizers(){
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleSingeleTap(recognizer:)))
        singleTapGesture.numberOfTapsRequired = 1
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleDoubleTap(recognizer:)))
        doubleTapGesture.numberOfTapsRequired = 2
        singleTapGesture.require(toFail: doubleTapGesture)
        
        fullImgScrollView.addGestureRecognizer(singleTapGesture)
        fullImgScrollView.addGestureRecognizer(doubleTapGesture)
    }
    
//MARK: - tap1, tap2
    @objc private func handleSingeleTap(recognizer: UITapGestureRecognizer){
        
        let newState:Bool = !(navigationController?.isNavigationBarHidden)!
        navigationController?.setNavigationBarHidden(newState , animated: true)
        fullImgScrollView.backgroundColor =  newState ? UIColor.black: UIColor.white
        visibilityState = newState
        setNeedsStatusBarAppearanceUpdate()
    }
    
    @objc private func handleDoubleTap(recognizer: UITapGestureRecognizer){
        
        if fullImgScrollView.zoomScale == 1 {
            fullImgScrollView.zoom(to: zoomRectForScale(scale: fullImgScrollView.maximumZoomScale, center: recognizer.location(in: recognizer.view)), animated: true)
        } else {
            fullImgScrollView.setZoomScale(1, animated: true)
        }
    }
    
//MARK: - zoom tap
    private func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = fullImgView.frame.size.height / scale
        zoomRect.size.width  = fullImgView.frame.size.width  / scale
        
        let newCenter = fullImgView.convert(center, from: fullImgScrollView)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        
        return zoomRect
    }
    
//MARK: - work with +/- img
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let centerPoint = CGPoint(x: fullImgScrollView.contentOffset.x + fullImgScrollView.bounds.width / 2,
                                  y: fullImgScrollView.contentOffset.y + fullImgScrollView.bounds.height / 2)
        
        coordinator.animate(alongsideTransition: { (context) -> Void in
            self.fullImgScrollView.contentOffset = CGPoint(x: centerPoint.x - size.width / 2,
                                                           y: centerPoint.y - size.height / 2)
        }, completion: nil)
    }
    
    private func setZoomParametersForSize(_ scrollViewSize: CGSize) {
        let imageSize = fullImgView.bounds.size
        
        let widthScale = scrollViewSize.width / imageSize.width
        let heightScale = scrollViewSize.height / imageSize.height
        let minScale = min(widthScale, heightScale)
        
        fullImgScrollView.minimumZoomScale = minScale
        fullImgScrollView.maximumZoomScale = 3.0
    }
    
    private func recenterImage() {
        let scrollViewSize = fullImgScrollView.bounds.size
        let imageSize = fullImgView.frame.size
        
        let horizontalSpace = imageSize.width < scrollViewSize.width ?
            (scrollViewSize.width - imageSize.width) / 2 : 0
        let verticalSpace = imageSize.height < scrollViewSize.height ?
            (scrollViewSize.height - imageSize.height) / 2 : 0
        
        fullImgScrollView.contentInset = UIEdgeInsets(top: verticalSpace,
                                                      left: horizontalSpace,
                                                      bottom: verticalSpace,
                                                      right: horizontalSpace)
    }
    
    override func viewWillLayoutSubviews() {
        setZoomParametersForSize(fullImgScrollView.bounds.size)
        if fullImgScrollView.zoomScale < fullImgScrollView.minimumZoomScale {
            fullImgScrollView.zoomScale = fullImgScrollView.minimumZoomScale
        }
        recenterImage()
    }
    
    
    
}

// MARK: - UIScrollViewDelegate
extension FullImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return fullImgView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        recenterImage()
    }
    
}
