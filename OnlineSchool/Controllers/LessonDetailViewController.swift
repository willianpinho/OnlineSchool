//
//  LessonDetailViewController.swift
//  OnlineSchool
//
//  Created by Willian Junior Peres de Pinho on 14/02/23.
//

import Foundation
import UIKit
import SwiftUI
import AVKit
import AVFoundation
import Reachability

struct LessonDetailViewControllerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = LessonDetailViewController
    var id: Int
    var lessons: [Lesson]
    
    func makeUIViewController(context: Context) -> LessonDetailViewController {
        let viewcontroller = LessonDetailViewController()
        viewcontroller.id = id
        viewcontroller.lessons = lessons
        
        return viewcontroller
    }
    
    func updateUIViewController(_ uiViewController: LessonDetailViewController, context: Context) {
        
    }
}

class LessonDetailViewController: UIViewController {
    var id: Int = 0
    var lessons: [Lesson]?
    var lesson: Lesson?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let thumbnailView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .clear
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nextLessonButton: UIButton = {
        let button = UIButton()
        button.setTitle("Next Lesson >", for: .normal)
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var downloadVideoSession: URLSession?
    private var downloadTask: URLSessionDownloadTask?
    private let downloadProgressView = UIProgressView()
    private var downloadAlertView: UIAlertController?
    private var folderDestinationUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshView()
    }
    
    func refreshView() {
        guard let currentLesson = lessons?[id] else { return }
        lesson = currentLesson
        downloadVideoSession = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue())
        folderDestinationUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("lesson-\(id).mp4")
        setupScrollView()
        setupChildViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        createDownloadButton()
    }
     
    func createDownloadButton() {
        let downloadButton = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
        downloadButton.tintColor = .systemBlue
        downloadButton.setTitleColor(.systemBlue, for: .normal)
        
        if downloadedVideo() {
            downloadButton.setTitle("Downloaded", for: .normal)
            downloadButton.setImage(UIImage(systemName: "icloud.and.arrow.up"), for: .normal)
        } else {
            downloadButton.setTitle("Download", for: .normal)
            downloadButton.setImage(UIImage(systemName: "icloud.and.arrow.down"), for: .normal)
        }
        
        downloadButton.addTarget(self, action: #selector(self.downloadVideo(_:)), for: .touchUpInside)
        
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(customView: downloadButton)
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        let safeArea = view.safeAreaLayoutGuide
        let scrollViewConstraints = [
            scrollView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ]
        NSLayoutConstraint.activate(scrollViewConstraints)
        
        let contentViewConstraints = [
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ]
        NSLayoutConstraint.activate(contentViewConstraints)
    }
    
    private func setupChildViews() {
        contentView.addSubview(thumbnailView)
        let thumbnailViewConstraints = [
            thumbnailView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            thumbnailView.topAnchor.constraint(equalTo: contentView.topAnchor),
            thumbnailView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            thumbnailView.heightAnchor.constraint(equalToConstant: 200)
        ]
        NSLayoutConstraint.activate(thumbnailViewConstraints)
        
        let playButton = UIButton()
        playButton.setImage(UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 50, weight: .bold, scale: .default)), for: .normal)
        playButton.tintColor = UIColor.white
        playButton.addTarget(self, action: #selector(self.playMovie), for: .touchUpInside)
        self.view.addSubview(playButton)
        
        playButton.translatesAutoresizingMaskIntoConstraints = false
        
        let playButtonConstraints = [
            playButton.centerXAnchor.constraint(equalTo: thumbnailView.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: thumbnailView.centerYAnchor)
        ]
        NSLayoutConstraint.activate(playButtonConstraints)
        
        contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabelConstraints = [
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            nameLabel.topAnchor.constraint(equalTo: thumbnailView.bottomAnchor, constant: 20),
            nameLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8)
        ]
        NSLayoutConstraint.activate(nameLabelConstraints)
        
        contentView.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let descriptionLabelConstraints = [
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            descriptionLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8)
        ]
        NSLayoutConstraint.activate(descriptionLabelConstraints)
        
        currentLesson()
        
        guard let lessons = lessons, id < lessons.count - 1 else {
            descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
            nextLessonButton.removeFromSuperview()
            return
        }
        
        nextLessonButton.addTarget(self, action: #selector(self.nextLesson), for: .touchUpInside)
        contentView.addSubview(nextLessonButton)
        nextLessonButton.translatesAutoresizingMaskIntoConstraints = false
        let nextLessonButtonConstraints = [
            nextLessonButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            nextLessonButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            nextLessonButton.widthAnchor.constraint(equalToConstant: 200),
            nextLessonButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ]
        NSLayoutConstraint.activate(nextLessonButtonConstraints)
    }
    
    private func currentLesson() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self,
                  let thumbnailURL = self.lesson?.thumbnail,
                  let data = try? Data(contentsOf: thumbnailURL) else {
                return
            }
            guard let image = UIImage(data: data) else {
                return
            }
            DispatchQueue.main.async {
                self.thumbnailView.image = image
            }
        }
        guard let lessons = lessons, let currentLesson = lessons[safe: id] else { return }
        nameLabel.text = currentLesson.name
        descriptionLabel.text = currentLesson.description
        nextLessonButton.isHidden = (id == lessons.count - 1)
    }
    
    @objc func playMovie(sender : UIButton) {
        guard let currentLesson = lessons?[id] else { return }
        var player = AVPlayer()
        NetworkManager.isReachable { nw in
            player = AVPlayer(url: currentLesson.videoURL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) { playerViewController.player?.play() }
        }
        
        NetworkManager.isUnreachable { nw in
            let playerItem = AVPlayerItem(url: self.folderDestinationUrl!)
            let player = AVPlayer(playerItem: playerItem)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) { playerViewController.player?.play() }
        }
    }
    
    @objc func nextLesson(sender : UIButton) {
        guard let lessons = lessons, id < lessons.count else {
            nextLessonButton.removeFromSuperview()
            return
        }
        
        lesson = lessons[id]
        currentLesson()
        id += 1

        let viewcontroller = LessonDetailViewController()
        viewcontroller.id = id
        viewcontroller.lessons = lessons
        
        self.navigationController?.pushViewController(viewcontroller, animated: false)
    }
    
    @objc func downloadVideo(_ sender: Any?) {
        
        if(downloadedVideo()){
            let alert = UIAlertController(title: "Alert", message: "You already downloaded", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        else{
            NetworkManager.isReachable { nw in
                let videoUrl = self.lesson!.videoURL
                
                self.downloadTask = self.downloadVideoSession!.downloadTask(with: videoUrl)
                self.downloadTask!.resume()
                self.downloadAlertView = UIAlertController(title: "Download Video\n", message: nil, preferredStyle: .alert)
                self.downloadAlertView!.addAction(UIAlertAction(title: "Cancel download", style: .cancel, handler: { [self] action in
                    downloadTask!.cancel()
                }))
                
                self.present(self.downloadAlertView!, animated: true, completion: { [self] in
                    let margin:CGFloat = 8.0
                    let rect = CGRect(x: margin, y: 60.0, width: downloadAlertView!.view.frame.width - margin * 2.0 , height: 22.0)
                    downloadProgressView.frame = rect
                    downloadProgressView.progress = 0.0
                    downloadProgressView.tintColor = .systemBlue
                    downloadAlertView!.view.addSubview(downloadProgressView)
                })
            }
            
            NetworkManager.isUnreachable { nw in
                let alert = UIAlertController(title: "Alert", message: "You can't download. Please check your network.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func downloadedVideo() -> Bool {
        return FileManager().fileExists(atPath: folderDestinationUrl!.path)
    }
}

extension LessonDetailViewController: URLSessionDownloadDelegate{
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            try FileManager.default.moveItem(at: location, to: folderDestinationUrl!)
            
            DispatchQueue.main.async {
                self.downloadAlertView?.dismiss(animated: true)
                
                let alert = UIAlertController(title: "Alert", message: "Download Completed", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        } catch {
            fatalError("Couldn't move item to destination: \(error.localizedDescription)")
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let percentDownloaded = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        DispatchQueue.main.async { [self] in
            downloadProgressView.progress = Float(percentDownloaded)
        }
    }
}
