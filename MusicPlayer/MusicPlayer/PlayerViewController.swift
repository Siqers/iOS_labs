import AVFoundation
import UIKit

@MainActor
final class PlayerViewController: UIViewController, AVAudioPlayerDelegate {
    @IBOutlet private var coverView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var artistLabel: UILabel!
    @IBOutlet private var playButton: UIButton!

    private var isChangingTrack = false

    private let tracks = TrackLibrary.tracks
    private var currentIndex = 0
    private var player: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Dynamic colors and label configuration for Light/Dark and readability
        view.backgroundColor = .systemBackground
        coverView.backgroundColor = .clear
        coverView.contentMode = .scaleAspectFit

        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8
        titleLabel.lineBreakMode = .byTruncatingTail

        artistLabel.textColor = .secondaryLabel
        artistLabel.numberOfLines = 1
        artistLabel.adjustsFontSizeToFitWidth = true
        artistLabel.minimumScaleFactor = 0.8

        updatePlayButton()
        loadTrack(autoplay: false)
    }

    @IBAction private func previous(_ sender: UIButton) {
        let feedback = UIImpactFeedbackGenerator(style: .light)
        feedback.impactOccurred()
        guard !isChangingTrack else { return }
        isChangingTrack = true
        changeTrack(by: -1, autoplay: player?.isPlaying == true)
        isChangingTrack = false
    }

    @IBAction private func next(_ sender: UIButton) {
        let feedback = UIImpactFeedbackGenerator(style: .light)
        feedback.impactOccurred()
        guard !isChangingTrack else { return }
        isChangingTrack = true
        changeTrack(by: 1, autoplay: player?.isPlaying == true)
        isChangingTrack = false
    }

    @IBAction private func togglePlayback(_ sender: UIButton) {
        guard !isChangingTrack else { return }
        let selection = UISelectionFeedbackGenerator()
        selection.selectionChanged()
        if let player {
            if player.isPlaying {
                player.pause()
            } else {
                startPlayback(player)
            }
            updatePlayButton()
        } else {
            loadTrack(autoplay: true)
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard self.player === player else { return }
        if flag {
            guard !isChangingTrack else { return }
            isChangingTrack = true
            changeTrack(by: 1, autoplay: true)
            isChangingTrack = false
        } else {
            print("Playback ended unexpectedly.")
            updatePlayButton()
        }
    }

    private func changeTrack(by offset: Int, autoplay: Bool) {
        guard !tracks.isEmpty else { return }
        let count = tracks.count
        currentIndex = (currentIndex + offset % count + count) % count
        loadTrack(autoplay: autoplay)
    }

    private func loadTrack(autoplay: Bool) {
        // Stop and release any existing player before configuring UI
        if let existing = player {
            existing.stop()
            existing.delegate = nil
        }
        player = nil

        defer { updatePlayButton() }

        guard tracks.indices.contains(currentIndex) else { return }
        let track = tracks[currentIndex]

        // Update UI with clear, animated transition
        animateTrackChange(for: track)

        // Prepare audio
        guard let url = Bundle.main.url(forResource: track.fileName, withExtension: "m4a") else {
            print("Missing audio file: \(track.fileName).m4a")
            return
        }
        do {
            let newPlayer = try AVAudioPlayer(contentsOf: url)
            newPlayer.delegate = self
            newPlayer.prepareToPlay()
            self.player = newPlayer
            if autoplay { startPlayback(newPlayer) }
        } catch {
            print("Could not load \(track.fileName): \(error.localizedDescription)")
        }
    }

    private func startPlayback(_ player: AVAudioPlayer) {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback)
            try session.setActive(true)
            if !player.play() { print("Could not start playback.") }
        } catch {
            print("Could not activate audio: \(error.localizedDescription)")
        }
    }

    private func updatePlayButton() {
        let isPlaying = player?.isPlaying == true
        let imageName = isPlaying ? "pause.fill" : "play.fill"
        let image = UIImage(systemName: imageName)

        if #available(iOS 15.0, *) {
            var config = playButton.configuration ?? .tinted()
            config.image = image
            config.baseForegroundColor = .label
            config.baseBackgroundColor = .clear
            playButton.configuration = config
            playButton.setTitle("", for: .normal)
        } else {
            playButton.setImage(image, for: .normal)
            playButton.setTitle("", for: .normal)
            playButton.tintColor = .label
            playButton.backgroundColor = .clear
        }
        playButton.accessibilityLabel = isPlaying ? "Pause" : "Play"
    }

    private func animateTrackChange(for track: Track) {
        // Cross-dissolve the cover and labels for clearer perception of change
        UIView.transition(with: coverView, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.coverView.image = UIImage(named: track.coverImageName)
        })
        UIView.transition(with: titleLabel, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.titleLabel.text = track.title
        })
        UIView.transition(with: artistLabel, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.artistLabel.text = track.artist
        })

        // Subtle scale animation on cover for additional visual feedback
        UIView.animate(withDuration: 0.18, animations: {
            self.coverView.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }, completion: { _ in
            UIView.animate(withDuration: 0.18) {
                self.coverView.transform = .identity
            }
        })

        // VoiceOver announcement for accessibility
        UIAccessibility.post(notification: .announcement, argument: "\(track.title) — \(track.artist)")
    }

    deinit {
        player?.stop()
        player?.delegate = nil
    }
}
