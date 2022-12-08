//
//  ContentView.swift
//  ml-stable-diffusion-ios-demo
//
//  Created by 宮本大新 on 2022/12/08.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            Text(viewModel.status.message)
                .foregroundColor(.primary)
                .font(.system(size: 25, weight: .bold))
            if viewModel.status == .generateStart {
                ProgressView(value: .init(Double(viewModel.step)), total: .init(Double(viewModel.stepCount))) {
                    Text("生成中")
                } currentValueLabel: {
                    Text("(\(viewModel.step)/\(Int(viewModel.stepCount)))")
                }
                .progressViewStyle(CircularProgressViewStyle())
            }
            if let image = viewModel.image {
                slideImageView(image: image)
            } else {
                Text("画像を生成してください")
                    .frame(maxWidth: .infinity, minHeight: 300)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(10)
            }
            GroupBox("Prompt") {
                TextField("プロンプトを入力してください", text: $viewModel.prompt, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .disabled(viewModel.status == .generateStart)
            }
            GroupBox("Image Count") {
                Stepper(value: $viewModel.imageCount, in: 1...4) {
                    Text("\(viewModel.imageCount)")
                }
                .disabled(viewModel.status == .generateStart)
            }
            GroupBox("Step Count") {
                Text(Int(viewModel.stepCount).description)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Slider(value: $viewModel.stepCount, in: 1...50, step: 1)
                    .disabled(viewModel.status == .generateStart)
            }
            GroupBox("Seed") {
                Text(Int(viewModel.seed).description)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Slider(value: $viewModel.seed, in: 0...1000, step: 1)
                    .disabled(viewModel.status == .generateStart)
            }
            Button {
                Task.init {
                    await viewModel.generateImage()
                }
            } label: {
                Text("生成")
                    .foregroundColor(.white)
                    .font(.system(size: 25, weight: .bold))
                    .frame(maxWidth: .infinity, minHeight: 70)
            }
            .frame(maxWidth: .infinity, minHeight: 70)
            .background(viewModel.status != .loadFinish || viewModel.status == .generateStart || viewModel.prompt == "" ? Color.secondary : Color.blue)
            .cornerRadius(10)
            .disabled(viewModel.status != .loadFinish || viewModel.status == .generateStart || viewModel.prompt == "")
        }
        .padding(.all)
        .task {
            Task.init {
                await viewModel.loadModels()
            }
        }
    }

    private func slideImageView(image: [CGImage]) -> some View {
        TabView {
            ForEach(0..<image.count, id: \.self) { index in
                Image(image[index], scale: 1.0, label: Text("生成画像"))
                    .resizable()
                    .scaledToFit()
            }
        }
        .tabViewStyle(.page)
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .interactive))
        .frame(maxWidth: .infinity, minHeight: 400)
        .background(Color(uiColor: .secondarySystemFill))
        .cornerRadius(10)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
