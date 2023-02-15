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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let currentLesson = lessons?[id] else { return }
        lesson = currentLesson
        setupScrollView()
        setupChildViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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

        let player = AVPlayer(url: currentLesson.videoURL)
        
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) { playerViewController.player?.play() }
    }
    
    @objc func nextLesson(sender : UIButton) {
        guard let lessons = lessons, id < lessons.count else {
            nextLessonButton.removeFromSuperview()
            return
        }
        
        lesson = lessons[id]
        currentLesson()
        id += 1
    }
}
