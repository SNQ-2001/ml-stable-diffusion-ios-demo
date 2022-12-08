//
//  ViewModel.swift
//  ml-stable-diffusion-ios-demo
//
//  Created by 宮本大新 on 2022/12/08.
//

import Foundation
import StableDiffusion
import CoreGraphics

final class ViewModel: ObservableObject {
    @Published var pipeline: StableDiffusionPipeline?
    @Published var image: [CGImage]?
    @Published var prompt: String = "cat"
    @Published var imageCount: Int = 1
    @Published var stepCount: Double = 30
    @Published var seed: Double = 500
    @Published var step: Int = 0
    @Published var status: StableDiffusionStatus = .ready

    func loadModels() async {
        guard let resourceURL = Bundle.main.resourceURL else { return }
        do {
            Task.detached { @MainActor in
                self.status = .loadStart
            }
            let pipeline = try StableDiffusionPipeline(resourcesAt: resourceURL)
            Task.detached { @MainActor in
                self.pipeline = pipeline
                self.status = .loadFinish
            }
        } catch {
            Task.detached { @MainActor in
                self.status = .error
            }
        }
    }

    func generateImage() async {
        do {
            Task.detached { @MainActor in
                self.image = nil
                self.status = .generateStart
            }
            let image = try self.pipeline?.generateImages(
                prompt: self.prompt,
                imageCount: self.imageCount,
                stepCount: Int(self.stepCount),
                seed: Int(self.seed),
                disableSafety: true
            ) { data in
                Task.detached { @MainActor in
                    self.image = data.currentImages.map({ cgImage in
                        guard let cgImage else { fatalError() }
                        return cgImage
                    })
                    self.step = data.step
                }
                return true
            }.map({ cgImage in
                guard let cgImage else { fatalError() }
                return cgImage
            })
            Task.detached { @MainActor in
                self.image = image
                self.status = .generateFinish
            }
        } catch {
            Task.detached { @MainActor in
                self.status = .error
            }
        }
    }
}
