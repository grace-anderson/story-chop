import Foundation
import Speech
import AVFoundation

@Observable final class TranscriptionService {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechURLRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    var isTranscribing = false
    var transcriptionResult: String?
    var errorMessage: String?
    
    init() {
        print("[DEBUG] TranscriptionService initialized")
        // Request speech recognition authorization
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    print("[DEBUG] Speech recognition authorized")
                case .denied:
                    print("[DEBUG] Speech recognition denied")
                    self?.errorMessage = "Speech recognition access denied"
                case .restricted:
                    print("[DEBUG] Speech recognition restricted")
                    self?.errorMessage = "Speech recognition restricted on this device"
                case .notDetermined:
                    print("[DEBUG] Speech recognition not determined")
                    self?.errorMessage = "Speech recognition authorization not determined"
                @unknown default:
                    print("[DEBUG] Speech recognition unknown authorization status")
                    self?.errorMessage = "Unknown speech recognition authorization status"
                }
            }
        }
    }
    
    func transcribeAudio(filePath: String, completion: @escaping (Result<String, Error>) -> Void) {
        print("[DEBUG] Starting transcription for file: \(filePath)")
        
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            print("[DEBUG] Speech recognizer not available")
            completion(.failure(TranscriptionError.speechRecognizerNotAvailable))
            return
        }
        
        let fileURL = URL(fileURLWithPath: filePath)
        guard FileManager.default.fileExists(atPath: filePath) else {
            print("[DEBUG] Audio file not found at path: \(filePath)")
            completion(.failure(TranscriptionError.fileNotFound))
            return
        }
        
        isTranscribing = true
        errorMessage = nil
        
        // Create recognition request
        recognitionRequest = SFSpeechURLRecognitionRequest(url: fileURL)
        guard let recognitionRequest = recognitionRequest else {
            print("[DEBUG] Failed to create recognition request")
            isTranscribing = false
            completion(.failure(TranscriptionError.recognitionRequestFailed))
            return
        }
        
        // Configure recognition request
        recognitionRequest.shouldReportPartialResults = false
        
        // Start recognition task
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isTranscribing = false
                
                if let error = error {
                    print("[DEBUG] Transcription error: \(error)")
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                    return
                }
                
                guard let result = result else {
                    print("[DEBUG] No transcription result")
                    self?.errorMessage = "No transcription result"
                    completion(.failure(TranscriptionError.noResult))
                    return
                }
                
                let transcribedText = result.bestTranscription.formattedString
                print("[DEBUG] Transcription completed successfully, text length: \(transcribedText.count)")
                self?.transcriptionResult = transcribedText
                completion(.success(transcribedText))
            }
        }
    }
    
    func cancelTranscription() {
        print("[DEBUG] Canceling transcription")
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        isTranscribing = false
    }
}

// Custom error types for transcription
enum TranscriptionError: LocalizedError {
    case speechRecognizerNotAvailable
    case fileNotFound
    case recognitionRequestFailed
    case noResult
    
    var errorDescription: String? {
        switch self {
        case .speechRecognizerNotAvailable:
            return "Speech recognition is not available on this device"
        case .fileNotFound:
            return "Audio file not found"
        case .recognitionRequestFailed:
            return "Failed to create recognition request"
        case .noResult:
            return "No transcription result available"
        }
    }
} 