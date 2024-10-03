//
//  ContentView.swift
//  iosGPUCalculate
//
//  Created by Ian Brown on 10/1/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var metalManager = MetalManager()
    @State private var resultsmallCPU: String = ""
    @State private var resultsmallGPU: String = ""
    @State private var resultBigCPU: String = ""
    @State private var resultBigGPU: String = ""
    @State private var bigA: [Float] = []
    @State private var bigB: [Float] = []
    
    var body: some View {
        let A: [Float] = [1.0, 2.0, 3.0]
        let B: [Float] = [4.0, 5.0, 6.0]

        VStack {
            Button(action: {
                resultsmallCPU = metalManager.calcCPU_ApB(A: A, B: B)
            }) {
                Text("Use CPU to calculate")
            }
            Text("zip(A, B).map(+) \n Vector A is \(A) \n Vector B is \(B) \n \(resultsmallCPU)")
            
            Button(action: {
                resultsmallGPU = metalManager.calcGPU_ApB(A: A, B: B)!
            }) {
                Text("Use GPU to calculate")
            }
            Text("Vector A is \(A) \n Vector B is \(B) \n \(resultsmallGPU)")
            
            Text("")
            
            Button(action: {
                resultBigCPU = metalManager.calcCPU_ApB(A: bigA, B: bigB)
            }) {
                Text("BIG Array CPU to calculate")
            }
            Text("zip(A, B).map(+) \n Vector A is \(bigA.count) elements \n Vector B is \(bigB.count) elements \n \(resultBigCPU)")
            
            Button(action: {
                resultBigGPU = metalManager.calcGPU_ApB(A: bigA, B: bigB)!
            }) {
                Text("BIG Array GPU to calculate")
            }
            Text("Vector A is \(bigA.count) elements \nVector B is \(bigB.count) elements \n \(resultBigGPU)")
        }
        .onAppear {
            // Generate the big arrays only once when the view appears
            bigA = metalManager.makeBigArray(size: 1_000_000)
            bigB = bigA  // Had to do to get same array/result
        }
        .padding()
    }
}


#Preview {
    ContentView()
}
