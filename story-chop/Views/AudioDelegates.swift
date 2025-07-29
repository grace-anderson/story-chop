import Foundation
import AVFoundation

// Audio Recorder Delegate
class AudioRecorderDelegate: NSObject, AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("[DEBUG] Audio recording finished - success: \(flag)")
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("[DEBUG] Audio recording encode error: \(error?.localizedDescription ?? "unknown error")")
    }
}

// Audio Player Delegate
class AudioPlayerDelegate: NSObject, AVAudioPlayerDelegate {
    private let completionHandler: (AVAudioPlayer?) -> Void
    
    init(completionHandler: @escaping (AVAudioPlayer?) -> Void) {
        self.completionHandler = completionHandler
        super.init()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("[DEBUG] AudioPlayerDelegate: playback finished successfully: \(flag)")
        completionHandler(player)
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("[DEBUG] AudioPlayerDelegate: decode error occurred: \(error?.localizedDescription ?? "unknown error")")
        completionHandler(player)
    }
} 