import SwiftUI
import UIKit
import Vision

class VisionTextRecognizer: ObservableObject {
    @Published var recognizedText: String = ""
    @Published var isProcessing: Bool = false
    @Published var error: String?
    
    func recognizeText(from image: CGImage) {
        isProcessing = true
        error = nil
        
        let request = VNRecognizeTextRequest { [weak self] request, error in
            DispatchQueue.main.async {
                self?.isProcessing = false
                
                if let error = error {
                    self?.error = error.localizedDescription
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    self?.error = "No text found in image"
                    return
                }
                
                let text = observations
                    .compactMap { $0.topCandidates(1).first?.string }
                    .joined(separator: " ")
                
                self?.recognizedText = text
                
                if text.isEmpty {
                    self?.error = "No readable text detected. Try better lighting or a clearer image."
                }
            }
        }
        

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["en-US"]
        

        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.error = error.localizedDescription
                }
            }
        }
    }
    
    func recognizeText(from uiImage: UIImage) {
        guard let cgImage = uiImage.cgImage else {
            error = "Could not process image"
            return
        }
        recognizeText(from: cgImage)
    }
    
    func reset() {
        recognizedText = ""
        isProcessing = false
        error = nil
    }
}
