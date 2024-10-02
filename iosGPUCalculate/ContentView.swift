//
//  ContentView.swift
//  iosGPUCalculate
//
//  Created by Ian Brown on 10/1/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var metalManager = MetalManager()

    var body: some View {
        VStack {
            Text("Metal GPU Calculation")
            Button("Calculate") {
                metalManager.performCalculation()
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

//struct ContentView: View {
//    @StateObject private var metalManager = MetalManager()
//
//    var body: some View {
//        VStack {
//            Text("Metal GPU Calculation")
//            Button("Calculate") {
//                metalManager.performCalculation()
//            }
//        }
//        .padding()
//    }
//}
