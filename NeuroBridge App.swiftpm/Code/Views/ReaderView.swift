import SwiftUI
import UIKit

struct ReaderView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var showSettings: Bool
    @ObservedObject private var fontManager = FontManager.shared
    @State private var selectedTextSource: TextSource = .samples
    @State private var currentText: String = ""
    @State private var showingCamera = false
    @State private var selectedSampleId: String? = nil
    @State private var navigateToTransformedText = false
    
    enum TextSource: String, CaseIterable {
        case samples = "Samples"
        case camera = "Camera"
        case manual = "Type"
        
        var icon: String {
            switch self {
            case .samples: return "book.fill"
            case .camera: return "camera.fill"
            case .manual: return "keyboard"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.neuroBackground.ignoresSafeArea()
                themeManager.currentTheme.accentGlow
                    .opacity(0.4)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Picker("Text Source", selection: $selectedTextSource) {
                        ForEach(TextSource.allCases, id: \.self) { source in
                            Image(systemName: source.icon)
                                .tag(source)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    switch selectedTextSource {
                    case .samples:
                        SampleTextsView(selectedId: $selectedSampleId, onSelect: { sample in
                            currentText = sample.content
                            selectedSampleId = sample.id
                        })
                    case .camera:
                        CameraScanView(onTextRecognized: { text in
                            currentText = text
                            navigateToTransformedText = true
                        })
                    case .manual:
                        ManualTextInputView(text: $currentText)
                    }
                    
                    if !currentText.isEmpty && selectedTextSource != .camera {
                        NavigationLink {
                            TransformedTextView(text: currentText)
                        } label: {
                            HStack {
                                Image(systemName: "wand.and.stars")
                                Text("View Transformed Text")
                            }
                            .font(Font.appFont(size: 17, weight: .semibold, context: .general))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.neuroPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .padding(.horizontal)
                        .simultaneousGesture(TapGesture().onEnded {
                            HapticManager.shared.buttonPress()
                        })
                    }
                }
            }
            .navigationTitle("Reader")
            .navigationDestination(isPresented: $navigateToTransformedText) {
                if !currentText.isEmpty {
                    TransformedTextView(text: currentText)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.neuroPrimary)
                    }
                }
            }
            .id(FontManager.shared.selectedVariant.rawValue + FontManager.shared.selectedUsage.rawValue)
        }
    }
}


struct SampleTextsView: View {
    @Binding var selectedId: String?
    let onSelect: (SampleText) -> Void
    
    private var groupedSamples: [(SampleText.Difficulty, [SampleText])] {
        let grouped = Dictionary(grouping: SampleText.samples, by: \.difficulty)
        return SampleText.Difficulty.allCases.compactMap { difficulty in
            guard let texts = grouped[difficulty], !texts.isEmpty else { return nil }
            return (difficulty, texts)
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(groupedSamples, id: \.0) { difficulty, texts in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(difficulty.color)
                                .frame(width: 10, height: 10)
                            Text(difficulty.rawValue)
                                .font(Font.appFont(size: 16, weight: .bold, design: .rounded, context: .general))
                                .foregroundColor(.white)
                            Text("(\(texts.count))")
                                .font(Font.appFont(size: 14, weight: .medium, design: .rounded, context: .general))
                                .foregroundColor(.neuroTextMuted)
                        }
                        .padding(.horizontal, 4)
                        
                        ForEach(texts) { sample in
                            SampleTextCard(
                                sample: sample,
                                isSelected: selectedId == sample.id
                            ) {
                                HapticManager.shared.selection()
                                onSelect(sample)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .responsiveContent()
        }
    }
}


struct ManualTextInputView: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Type or paste your text below")
                .font(.neuroSubheadline)
                .foregroundColor(.neuroTextSecondary)
            
            TextEditor(text: $text)
                .font(.neuroBody)
                .foregroundColor(.white)
                .scrollContentBackground(.hidden)
                .padding()
                .background(Color.neuroSurface)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isFocused ? Color.neuroPrimary : Color.white.opacity(0.1), lineWidth: 2)
                )
                .focused($isFocused)
            
            if !text.isEmpty {
                HStack {
                    Text("\(text.split(separator: " ").count) words")
                        .font(.neuroCaption)
                        .foregroundColor(.neuroTextMuted)
                    
                    Spacer()
                    
                    Button("Clear") {
                        text = ""
                        HapticManager.shared.tap()
                    }
                    .font(.neuroCaption)
                    .foregroundColor(.neuroError)
                }
            }
        }
        .padding(.horizontal)
    }
}


struct CameraScanView: View {
    let onTextRecognized: (String) -> Void
    @StateObject private var recognizer = VisionTextRecognizer()
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var capturedImage: UIImage?
    @State private var showCropView = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            if recognizer.isProcessing {
                VStack(spacing: 16) {
                    ProgressView()
                        .tint(.neuroPrimary)
                        .scaleEffect(1.5)
                    Text("Scanning text...")
                        .font(.neuroBody)
                        .foregroundColor(.neuroTextSecondary)
                }
            } else if !recognizer.recognizedText.isEmpty {

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(.neuroPrimary)
                        Text("Recognized Text")
                            .font(.neuroHeadline)
                            .foregroundColor(.white)
                        Spacer()
                        Button {
                            recognizer.recognizedText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.neuroTextMuted)
                        }
                    }
                    
                    ScrollView {
                        Text(recognizer.recognizedText)
                            .font(.neuroBody)
                            .foregroundColor(.white)
                    }
                    .frame(maxHeight: 200)
                    .padding()
                    .background(Color.neuroSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    Button {
                        HapticManager.shared.buttonPress()
                        onTextRecognized(recognizer.recognizedText)
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Use This Text")
                        }
                    }
                    .buttonStyle(NeuroButtonStyle())
                    .frame(maxWidth: .infinity)
                    
                    Button {
                        recognizer.recognizedText = ""
                        capturedImage = nil
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Scan Another")
                        }
                        .font(Font.appFont(size: 17, weight: .semibold, context: .general))
                        .foregroundColor(.neuroTextSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
            } else {

                ZStack {
                    Circle()
                        .fill(Color.neuroSurface)
                        .frame(width: 120.adaptive, height: 120.adaptive)
                    
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 50.adaptive))
                        .foregroundColor(.neuroPrimary)
                }
                
                Text("Scan Text from Photos")
                    .font(Font.appFont(size: 20, weight: .bold, design: .rounded, context: .general, isAlreadyAdaptive: true))
                    .foregroundColor(.white)
                    .lineLimit(nil)
                    .minimumScaleFactor(0.7)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                
                Text("Take a photo or choose from library.\nYou can select a specific area to scan.")
                    .font(Font.appFont(size: 14, weight: .regular, design: .rounded, context: .general, isAlreadyAdaptive: true))
                    .foregroundColor(.neuroTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .minimumScaleFactor(0.7)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 40)
                
                VStack(spacing: 12.adaptive) {
                    Button {
                        HapticManager.shared.buttonPress()
                        showingCamera = true
                    } label: {
                        HStack {
                            Image(systemName: "camera.fill")
                            Text("Take Photo")
                        }
                        .font(Font.appFont(size: 15, weight: .medium, design: .rounded, context: .general))
                        .foregroundColor(.white)
                        .padding(.vertical, 12.adaptive)
                        .padding(.horizontal, 24.adaptive)
                        .background(Color.neuroPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 16.adaptive))
                    }
                    
                    Button {
                        HapticManager.shared.buttonPress()
                        showingImagePicker = true
                    } label: {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                            Text("Choose from Library")
                        }
                        .font(Font.appFont(size: 15, weight: .medium, design: .rounded, context: .general))
                        .foregroundColor(.neuroPrimary)
                        .padding(.vertical, 12.adaptive)
                        .padding(.horizontal, 24.adaptive)
                        .background(Color.neuroSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 16.adaptive))
                    }
                }
            }
            
            if let error = recognizer.error {
                Text(error)
                    .font(.neuroCaption)
                    .foregroundColor(.neuroError)
                    .padding()
            }
            
            Spacer()
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $capturedImage, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $showingCamera) {
            ImagePicker(image: $capturedImage, sourceType: .camera)
        }
        .onChange(of: capturedImage) { _, newImage in
            if newImage != nil {
                showCropView = true
            }
        }
        .fullScreenCover(isPresented: $showCropView) {
            if let image = capturedImage {
                ImageCropView(image: image) { croppedImage in
                    showCropView = false
                    recognizer.recognizeText(from: croppedImage)
                } onCancel: {
                    showCropView = false
                    capturedImage = nil
                }
            }
        }
    }
}


// MARK: - Image Crop View

struct ImageCropView: View {
    let image: UIImage
    let onCrop: (UIImage) -> Void
    let onCancel: () -> Void
    
    @State private var cropRect: CGRect = .zero
    @State private var imageDisplaySize: CGSize = .zero
    @State private var imageOffset: CGPoint = .zero
    @State private var dragStart: CGPoint = .zero
    @State private var activeHandle: CropHandle? = nil
    
    enum CropHandle {
        case topLeft, topRight, bottomLeft, bottomRight, body
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
          
                HStack {
                    Button(action: onCancel) {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark")
                            Text("Cancel")
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("Select Area")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
       
                    HStack(spacing: 6) {
                        Image(systemName: "xmark")
                        Text("Cancel")
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.clear)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)
   
                GeometryReader { geo in
                    let displaySize = calculateDisplaySize(for: image, in: geo.size)
                    let offsetX = (geo.size.width - displaySize.width) / 2
                    let offsetY = (geo.size.height - displaySize.height) / 2
                    
                    ZStack {
                 
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: displaySize.width, height: displaySize.height)
                            .position(x: geo.size.width / 2, y: geo.size.height / 2)
                            .opacity(0.4)

                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: displaySize.width, height: displaySize.height)
                            .position(x: geo.size.width / 2, y: geo.size.height / 2)
                            .mask(
                                Rectangle()
                                    .frame(width: cropRect.width, height: cropRect.height)
                                    .position(x: cropRect.midX, y: cropRect.midY)
                            )

                        Rectangle()
                            .stroke(Color.white, lineWidth: 2)
                            .frame(width: cropRect.width, height: cropRect.height)
                            .position(
                                x: cropRect.midX,
                                y: cropRect.midY
                            )
        
                        Path { path in
                            let thirdW = cropRect.width / 3
                            let thirdH = cropRect.height / 3
                            
                            for i in 1...2 {
                                path.move(to: CGPoint(x: cropRect.minX + thirdW * CGFloat(i), y: cropRect.minY))
                                path.addLine(to: CGPoint(x: cropRect.minX + thirdW * CGFloat(i), y: cropRect.maxY))
                                path.move(to: CGPoint(x: cropRect.minX, y: cropRect.minY + thirdH * CGFloat(i)))
                                path.addLine(to: CGPoint(x: cropRect.maxX, y: cropRect.minY + thirdH * CGFloat(i)))
                            }
                        }
                        .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
   
                        CropCornerHandle()
                            .position(x: cropRect.minX, y: cropRect.minY)
                        CropCornerHandle()
                            .position(x: cropRect.maxX, y: cropRect.minY)
                        CropCornerHandle()
                            .position(x: cropRect.minX, y: cropRect.maxY)
                        CropCornerHandle()
                            .position(x: cropRect.maxX, y: cropRect.maxY)

                        Color.clear
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 1)
                                    .onChanged { value in
                                        handleDrag(value: value, imgOffX: offsetX, imgOffY: offsetY, imgW: displaySize.width, imgH: displaySize.height)
                                    }
                                    .onEnded { _ in
                                        activeHandle = nil
                                    }
                            )
                    }
                    .onAppear {
                        imageDisplaySize = displaySize
                        imageOffset = CGPoint(x: offsetX, y: offsetY)
                        let inset: CGFloat = 20
                        cropRect = CGRect(
                            x: offsetX + inset,
                            y: offsetY + inset,
                            width: displaySize.width - inset * 2,
                            height: displaySize.height - inset * 2
                        )
                    }
                }

                HStack(spacing: 16) {
                    Button {
                        let cropped = image
                        onCrop(cropped)
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "photo")
                                .font(.title2)
                            Text("Entire Image")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    
                    Button {
                        let cropped = cropImage()
                        onCrop(cropped)
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "crop")
                                .font(.title2)
                            Text("Use Selection")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.neuroPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .padding(.bottom, 10)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func calculateDisplaySize(for image: UIImage, in containerSize: CGSize) -> CGSize {
        let imageAspect = image.size.width / image.size.height
        let containerAspect = containerSize.width / containerSize.height
        
        if imageAspect > containerAspect {
            let width = containerSize.width
            return CGSize(width: width, height: width / imageAspect)
        } else {
            let height = containerSize.height
            return CGSize(width: height * imageAspect, height: height)
        }
    }
    
    private func handleDrag(value: DragGesture.Value, imgOffX: CGFloat, imgOffY: CGFloat, imgW: CGFloat, imgH: CGFloat) {
        let loc = value.location
        let handleRadius: CGFloat = 44

        let imgMinX = imgOffX
        let imgMinY = imgOffY
        let imgMaxX = imgOffX + imgW
        let imgMaxY = imgOffY + imgH
        
        if activeHandle == nil {
            let corners: [(CropHandle, CGPoint)] = [
                (.topLeft, CGPoint(x: cropRect.minX, y: cropRect.minY)),
                (.topRight, CGPoint(x: cropRect.maxX, y: cropRect.minY)),
                (.bottomLeft, CGPoint(x: cropRect.minX, y: cropRect.maxY)),
                (.bottomRight, CGPoint(x: cropRect.maxX, y: cropRect.maxY))
            ]
            
            for (handle, corner) in corners {
                if hypot(value.startLocation.x - corner.x, value.startLocation.y - corner.y) < handleRadius {
                    activeHandle = handle
                    break
                }
            }
            
            if activeHandle == nil && cropRect.contains(value.startLocation) {
                activeHandle = .body
                dragStart = value.startLocation
            }
        }
        
        let minSize: CGFloat = 60
        
        switch activeHandle {
        case .topLeft:
            let newX = max(imgMinX, min(loc.x, cropRect.maxX - minSize))
            let newY = max(imgMinY, min(loc.y, cropRect.maxY - minSize))
            cropRect = CGRect(x: newX, y: newY, width: cropRect.maxX - newX, height: cropRect.maxY - newY)
        case .topRight:
            let newMaxX = min(imgMaxX, max(loc.x, cropRect.minX + minSize))
            let newY = max(imgMinY, min(loc.y, cropRect.maxY - minSize))
            cropRect = CGRect(x: cropRect.minX, y: newY, width: newMaxX - cropRect.minX, height: cropRect.maxY - newY)
        case .bottomLeft:
            let newX = max(imgMinX, min(loc.x, cropRect.maxX - minSize))
            let newMaxY = min(imgMaxY, max(loc.y, cropRect.minY + minSize))
            cropRect = CGRect(x: newX, y: cropRect.minY, width: cropRect.maxX - newX, height: newMaxY - cropRect.minY)
        case .bottomRight:
            let newMaxX = min(imgMaxX, max(loc.x, cropRect.minX + minSize))
            let newMaxY = min(imgMaxY, max(loc.y, cropRect.minY + minSize))
            cropRect = CGRect(x: cropRect.minX, y: cropRect.minY, width: newMaxX - cropRect.minX, height: newMaxY - cropRect.minY)
        case .body:
            let dx = loc.x - dragStart.x
            let dy = loc.y - dragStart.y
            var newRect = cropRect.offsetBy(dx: dx, dy: dy)
            newRect.origin.x = max(imgMinX, min(newRect.origin.x, imgMaxX - newRect.width))
            newRect.origin.y = max(imgMinY, min(newRect.origin.y, imgMaxY - newRect.height))
            cropRect = newRect
            dragStart = loc
        case nil:
            break
        }
    }
    
    private func cropImage() -> UIImage {
  
        let normalized = normalizeOrientation(image)
        guard let cgImage = normalized.cgImage else { return image }
        
        let displaySize = imageDisplaySize
        guard displaySize.width > 0 && displaySize.height > 0 else { return image }
        
        let actualW = CGFloat(cgImage.width)
        let actualH = CGFloat(cgImage.height)

        let relX = cropRect.origin.x - imageOffset.x
        let relY = cropRect.origin.y - imageOffset.y
        let relW = cropRect.width
        let relH = cropRect.height

        let scaleX = actualW / displaySize.width
        let scaleY = actualH / displaySize.height
        
        let pixelX = max(0, relX * scaleX)
        let pixelY = max(0, relY * scaleY)
        let pixelW = min(relW * scaleX, actualW - pixelX)
        let pixelH = min(relH * scaleY, actualH - pixelY)
        
        guard pixelW > 0 && pixelH > 0 else { return image }
        
        let cropCGRect = CGRect(x: pixelX, y: pixelY, width: pixelW, height: pixelH)
        
        if let croppedCG = cgImage.cropping(to: cropCGRect) {
            return UIImage(cgImage: croppedCG)
        }
        
        return image
    }

    private func normalizeOrientation(_ img: UIImage) -> UIImage {
        guard img.imageOrientation != .up else { return img }
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = img.scale
        let renderer = UIGraphicsImageRenderer(size: img.size, format: format)
        let normalized = renderer.image { _ in
            img.draw(at: .zero)
        }
        return normalized
    }
}

struct CropCornerHandle: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 16, height: 16)
            Circle()
                .stroke(Color.neuroPrimary, lineWidth: 2)
                .frame(width: 16, height: 16)
        }
        .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 1)
    }
}


// MARK: - Image Picker

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}


struct TransformedTextView: View {
    let text: String
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var transformation: TextTransformation = TextTransformation()
    @State private var showSettings = false
    
    var body: some View {
        ZStack {
            Color.neuroBackground.ignoresSafeArea()
            themeManager.currentTheme.accentGlow
                .opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    DyslexiaTextView(text: text, transformation: transformation)
                        .padding()
                        .responsiveContent()
                }
                .background(transformation.overlayColor.color)
                Button {
                    HapticManager.shared.buttonPress()
                    showSettings = true
                } label: {
                    HStack {
                        Image(systemName: "slider.horizontal.3")
                        Text("Reading Preferences")
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(Color.neuroSurfaceLight)
                    .clipShape(Capsule())
                }
                .padding(.vertical, 8)
            }
        }
        .sheet(isPresented: $showSettings) {
            ZStack {
                Color.neuroBackground.ignoresSafeArea()
                
                VStack(spacing: 12) {
                    Text("Reader Settings")
                        .font(.neuroHeadline)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    ColorOverlayPicker(selectedColor: $transformation.overlayColor)
                    
                    HStack(spacing: 12) {
                        SettingToggle(
                            icon: "textformat",
                            title: "Dyslexic Font",
                            isOn: $transformation.useDyslexicFont
                        )
                        
                        SettingToggle(
                            icon: "text.word.spacing",
                            title: "Syllables",
                            isOn: $transformation.showSyllables
                        )
                        
                        SettingToggle(
                            icon: "eye",
                            title: "Focus",
                            isOn: $transformation.focusModeEnabled
                        )
                    }
                    
                    HStack(spacing: 24) {
                        VStack(alignment: .leading) {
                            Text("Size")
                                .font(.caption)
                                .foregroundColor(.neuroTextMuted)
                            Slider(value: $transformation.fontScale, in: 1.0...1.8)
                                .tint(.neuroPrimary)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Spacing")
                                .font(.caption)
                                .foregroundColor(.neuroTextMuted)
                            Slider(value: $transformation.letterSpacing, in: 0...8)
                                .tint(.neuroPrimary)
                        }
                    }
                    .padding(.bottom, 20)
                }
                .padding(.horizontal)
            }
            .presentationDetents([.height(360), .medium])
            .presentationDragIndicator(.visible)
        }
        .navigationTitle("Transformed Text")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            transformation = appState.currentTransformation
            let wordCount = text.split(separator: " ").count
            progressManager.addWordsRead(wordCount)
        }
        .onDisappear {
            appState.currentTransformation = transformation
        }
    }
}


struct SettingToggle: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        Button {
            HapticManager.shared.selection()
            isOn.toggle()
        } label: {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(isOn ? .white : .neuroTextMuted)
                    .frame(width: 44, height: 44)
                    .background(isOn ? Color.neuroPrimary : Color.neuroSurfaceLight)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Text(title)
                    .font(.caption2)
                    .foregroundColor(isOn ? .white : .neuroTextMuted)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }
}


enum ResetType: Identifiable, CaseIterable {
    case todaysProgress
    case achievements
    case allProgress
    
    var id: ResetType { self }
    
    var title: String {
        switch self {
        case .todaysProgress: return "Reset Today's Progress?"
        case .achievements: return "Reset Achievements?"
        case .allProgress: return "Reset All Progress?"
        }
    }
    
    var message: String {
        switch self {
        case .todaysProgress: return "Are you sure you want to reset today's reading and game progress? This cannot be undone."
        case .achievements: return "Are you sure you want to lock all unlocked achievements? This cannot be undone."
        case .allProgress: return "Are you sure you want to delete all historical reading stats, exercise history, and achievements? This cannot be undone."
        }
    }
}


struct ReadingSettingsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var fontManager = FontManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var transformation: TextTransformation = TextTransformation()
    @State private var showingResetAppAlert = false
    @State private var showingNameEditAlert = false
    @State private var newName = ""
    @State private var showingRemindersSheet = false
    @State private var resetType: ResetType? = nil
    @State private var showingResetProgressAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.neuroBackground.ignoresSafeArea()
                themeManager.currentTheme.accentGlow
                    .opacity(0.3)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                     
                        SettingsSection(title: "App Theme") {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(AppTheme.allCases) { theme in
                                        SettingsThemePill(
                                            theme: theme,
                                            isSelected: themeManager.currentTheme == theme
                                        ) {
                                            HapticManager.shared.selection()
                                            themeManager.setTheme(theme)
                                        }
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                        }
                    
                        SettingsSection(title: "Font Style") {
                            VStack(spacing: 12) {
                                HStack(spacing: 10) {
                                    ForEach(DyslexicFontVariant.allCases) { variant in
                                        FontVariantPill(
                                            variant: variant,
                                            isSelected: fontManager.selectedVariant == variant
                                        ) {
                                            HapticManager.shared.selection()
                                            fontManager.selectedVariant = variant
                                        }
                                    }
                                }
                              
                                Text("Reading feels easier now.")
                                    .font(Font.dyslexicOrSystem(size: 20.adaptive))
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.neuroSurfaceLight.opacity(0.5))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
              
                        SettingsSection(title: "Dyslexic Font Usage") {
                            VStack(spacing: 10) {
                                ForEach(DyslexicFontUsage.allCases) { usage in
                                    Button {
                                        HapticManager.shared.selection()
                                        fontManager.selectedUsage = usage
                                    } label: {
                                        HStack(spacing: 16.adaptive) {
                                            Image(systemName: fontManager.selectedUsage == usage ? "largecircle.fill.circle" : "circle")
                                                .font(.system(size: 20.adaptive))
                                                .foregroundColor(fontManager.selectedUsage == usage ? .neuroPrimary : .neuroTextMuted)
                                            
                                            Text(usage.rawValue)
                                                .font(.system(size: 16.adaptive, weight: .medium, design: .rounded))
                                                .foregroundColor(fontManager.selectedUsage == usage ? .white : .neuroTextSecondary)
                                            
                                            Spacer()
                                        }
                                        .padding(.horizontal, 16.adaptive)
                                        .padding(.vertical, 14.adaptive)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12.adaptive)
                                                .fill(fontManager.selectedUsage == usage ? Color.neuroPrimary.opacity(0.15) : Color.clear)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12.adaptive)
                                                .stroke(fontManager.selectedUsage == usage ? Color.neuroPrimary : Color.clear, lineWidth: 1.5)
                                        )
                                    }
                                }
                            }
                        }
                        
                        SettingsSection(title: "Typography") {
                            SettingsRow(title: "Use Dyslexic Font") {
                                Toggle("", isOn: $transformation.useDyslexicFont)
                                    .tint(.neuroPrimary)
                            }
                            
                            SettingsRow(title: "Font Size") {
                                Slider(value: $transformation.fontScale, in: 1.0...2.0)
                                    .tint(.neuroPrimary)
                            }
                            
                            SettingsRow(title: "Letter Spacing") {
                                Slider(value: $transformation.letterSpacing, in: 0...10)
                                    .tint(.neuroPrimary)
                            }
                            
                            SettingsRow(title: "Line Spacing") {
                                Slider(value: $transformation.lineSpacing, in: 4...24)
                                    .tint(.neuroPrimary)
                            }
                        }
                        
                        SettingsSection(title: "Visual Aids") {
                            SettingsRow(title: "Show Syllables") {
                                Toggle("", isOn: $transformation.showSyllables)
                                    .tint(.neuroPrimary)
                            }
                            
                            SettingsRow(title: "Focus Mode") {
                                Toggle("", isOn: $transformation.focusModeEnabled)
                                    .tint(.neuroPrimary)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Background Color")
                                    .font(.neuroBody)
                                    .foregroundColor(.white)
                                ColorOverlayPicker(selectedColor: $transformation.overlayColor)
                            }
                        }
            
                        SettingsSection(title: "Account & Preferences") {
                            SettingsRow(title: "Change Name") {
                                Button {
                                    newName = appState.userName
                                    showingNameEditAlert = true
                                } label: {
                                    Text("Edit")
                                        .font(.subheadline.bold())
                                        .foregroundColor(.neuroPrimary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.neuroPrimary.opacity(0.15))
                                        .cornerRadius(8)
                                }
                            }
                            
                            SettingsRow(title: "Reading Reminders") {
                                Button {
                                    showingRemindersSheet = true
                                } label: {
                                    Text("Manage")
                                        .font(.subheadline.bold())
                                        .foregroundColor(.neuroPrimary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.neuroPrimary.opacity(0.15))
                                        .cornerRadius(8)
                                }
                            }
                        }
                 
                        SettingsSection(title: "Data & Privacy") {
                            SettingsRow(title: "Reset Progress") {
                                Menu {
                                    Button(role: .destructive, action: {
                                        HapticManager.shared.buttonPress()
                                        resetType = .todaysProgress
                                        showingResetProgressAlert = true
                                    }) {
                                        Label("Reset Today's Progress", systemImage: "arrow.counterclockwise")
                                    }
                                    
                                    Button(role: .destructive, action: {
                                        HapticManager.shared.buttonPress()
                                        resetType = .achievements
                                        showingResetProgressAlert = true
                                    }) {
                                        Label("Reset Achievements", systemImage: "trophy")
                                    }
                                    
                                    Button(role: .destructive, action: {
                                        HapticManager.shared.buttonPress()
                                        resetType = .allProgress
                                        showingResetProgressAlert = true
                                    }) {
                                        Label("Reset All Progress", systemImage: "trash.fill")
                                    }
                                } label: {
                                    HStack {
                                        Text("Options")
                                        Image(systemName: "chevron.up.chevron.down")
                                            .font(.caption)
                                    }
                                    .foregroundColor(.neuroPrimary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.neuroPrimary.opacity(0.15))
                                    .cornerRadius(8)
                                }
                            }
                            .alert(resetType?.title ?? "Reset Progress", isPresented: $showingResetProgressAlert) {
                                Button("Cancel", role: .cancel) { }
                                Button("Reset", role: .destructive) {
                                    if let type = resetType {
                                        HapticManager.shared.buttonPress()
                                        switch type {
                                        case .todaysProgress:
                                            progressManager.resetTodaysProgress()
                                        case .achievements:
                                            progressManager.resetAchievements()
                                        case .allProgress:
                                            progressManager.resetAllProgress()
                                        }
                                    }
                                }
                            } message: {
                                Text(resetType?.message ?? "")
                            }
                            
                            Button(action: {
                                showingResetAppAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                    Text("Reset Entire App")
                                    Spacer()
                                }
                                .foregroundColor(Color.neuroWarning)
                                .font(.system(size: 16, weight: .bold))
                                .padding(.vertical, 4)
                            }
                            .alert("Reset Entire App?", isPresented: $showingResetAppAlert) {
                                Button("Cancel", role: .cancel) { }
                                Button("Reset", role: .destructive) {
                                    progressManager.resetAllProgress()
                                    appState.resetApp()
                                    dismiss()
                                }
                            } message: {
                                Text("This will delete all progress, achievements, user data, and restart the onboarding process. This action cannot be undone.")
                            }
                        }
                    }
                    .padding()
                    .responsiveContent()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        appState.currentTransformation = transformation
                        dismiss()
                    }
                    .foregroundColor(.neuroPrimary)
                }
            }
            .onAppear {
                transformation = appState.currentTransformation
            }
            .alert("Change Name", isPresented: $showingNameEditAlert) {
                TextField("Your Name", text: $newName)
                Button("Cancel", role: .cancel) { }
                Button("Save") {
                    appState.userName = newName
                }
            } message: {
                Text("Enter the name you'd like NeuroBridge to use when greeting you.")
            }
            .sheet(isPresented: $showingRemindersSheet) {
                ZStack {
                    Color.neuroBackground.ignoresSafeArea()
                    VStack {
                        RemindersSetupView(isSettingsContext: true) {
                            showingRemindersSheet = false
                        }
                    }
                }
            }
        }
    }
}


struct FontVariantPill: View {
    let variant: DyslexicFontVariant
    let isSelected: Bool
    let action: () -> Void
    
    private var pillFont: Font {
        let size: CGFloat = 24.adaptive
        if UIFont(name: variant.fontName, size: size) != nil {
            return Font.custom(variant.fontName, size: size)
        }
        switch variant {
        case .regular:
            return .system(size: size, weight: .regular, design: .rounded)
        case .bold:
            return .system(size: size, weight: .bold, design: .rounded)
        case .italic:
            return .system(size: size, weight: .regular, design: .rounded).italic()
        case .boldItalic:
            return .system(size: size, weight: .bold, design: .rounded).italic()
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text("Aa")
                    .font(pillFont)
                    .foregroundColor(isSelected ? .neuroPrimary : .neuroTextMuted)
                    .frame(width: 54.adaptive, height: 54.adaptive)
                    .background(
                        RoundedRectangle(cornerRadius: 10.adaptive)
                            .fill(isSelected ? Color.neuroPrimary.opacity(0.15) : Color.neuroSurfaceLight)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10.adaptive)
                            .stroke(isSelected ? Color.neuroPrimary : Color.clear, lineWidth: 1.5)
                    )
                
                Text(variant.rawValue)
                    .font(.system(size: 14.adaptive, weight: .medium, design: .rounded))
                    .foregroundColor(isSelected ? .white : .neuroTextMuted)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
        }
    }
}


struct SettingsThemePill: View {
    let theme: AppTheme
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                HStack(spacing: 3) {
                    ForEach(Array(theme.swatchColors.enumerated()), id: \.offset) { _, color in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(color)
                            .frame(width: 24.adaptive, height: 32.adaptive)
                    }
                }
                .padding(6)
                .background(
                    RoundedRectangle(cornerRadius: 10.adaptive)
                        .fill(Color.neuroSurface)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10.adaptive)
                        .stroke(isSelected ? theme.secondaryColor : Color.clear, lineWidth: 2)
                )
                
                Text(theme.rawValue)
                    .font(.system(size: 14.adaptive, weight: .medium, design: .rounded))
                    .foregroundColor(isSelected ? .white : .neuroTextMuted)
                    .lineLimit(1)
                    .frame(width: 90)
            }
        }
    }
}


struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 18.adaptive, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 16) {
                content
            }
            .neuroCard()
        }
    }
}


struct SettingsRow<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        HStack {
            Text(title)
                .font(.neuroBody)
                .foregroundColor(.white)
            
            Spacer()
            
            content
                .frame(maxWidth: 150)
        }
    }
}


#Preview {
    ReaderView(showSettings: .constant(false))
        .environmentObject(AppState())
        .environmentObject(ProgressManager())
        .environmentObject(ThemeManager.shared)
}
