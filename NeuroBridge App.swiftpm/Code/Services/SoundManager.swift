import AVFoundation

class SoundManager: NSObject {
    static let shared = SoundManager()
    
    private var correctPlayer: AVAudioPlayer?
    private var incorrectPlayer: AVAudioPlayer?
    private var completionPlayer: AVAudioPlayer?
    private var startReadingPlayer: AVAudioPlayer?
    
    private override init() {
        super.init()
        setupAudioSession()
        preparePlayers()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    private func preparePlayers() {
        correctPlayer = loadPlayer(filename: "correct", ext: "mp3")
        incorrectPlayer = loadPlayer(filename: "incorrect", ext: "mp3")
        completionPlayer = loadPlayer(filename: "exerciseComplete", ext: "mp3")
        startReadingPlayer = loadPlayer(filename: "onboarding", ext: "mp3")
    }
    
    private func loadPlayer(filename: String, ext: String) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: ext) else {
            print("Sound file not found: \(filename).\(ext)")
            return nil
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            return player
        } catch {
            print("Failed to load sound: \(filename).\(ext), error: \(error)")
            return nil
        }
    }
    
    func playCorrect() {
        correctPlayer?.currentTime = 0
        correctPlayer?.play()
    }
    
    func playIncorrect() {
        incorrectPlayer?.currentTime = 0
        incorrectPlayer?.play()
    }
    
    func playCompletion() {
        completionPlayer?.currentTime = 0
        completionPlayer?.play()
    }
    
    func playStartReading() {
        startReadingPlayer?.currentTime = 0
        startReadingPlayer?.play()
    }
}
