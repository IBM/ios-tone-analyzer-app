//
//  ToneItem.swift
//  toneanalyzerios
//
//  Created by Joshua Alger on 10/24/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Foundation
import ToneAnalyzerV3

//Class that will hold the Tone Category information for each cell
class ToneCategory{
    //String that holds tone category id
     var toneId: String!
    //String that holds tone category name
    var toneName: String!
    //ToneScore object array that holds the tones
    var toneScore: Double
    
    //Initialize the tone category
   init(toneId: String, toneName: String, toneScore: Double){
        self.toneId = toneId
        self.toneName = toneName
        self.toneScore = toneScore
    }
    
}
