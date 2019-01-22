/**
 * Copyright IBM Corporation 2018
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import Foundation

enum AnalyzerError: Error, CustomStringConvertible {

    case missingCredentials

    case invalidCredentials

    case noData

    case failedToAnalyzeTone

    case error(String)

    var title: String {
        switch self {
        case .missingCredentials: return "Missing Tone Analyzer Credentials"
        case .invalidCredentials: return "Invalid Tone Analyzer Credentials"
        case .noData: return "Bad Response"
        case .failedToAnalyzeTone: return "Bad Response"
        case .error: return "An error occurred"
        }
    }

    var message: String {
        switch self {
        case .missingCredentials: return "Please check the readme for more information on credentials configuration."
        case .invalidCredentials: return "Please check the readme for more information on credentials configuration."
        case .noData: return "No Tone Analyzer data was received."
        case .failedToAnalyzeTone: return "Failed to analyze the tone input."
        case .error(let msg): return msg
        }
    }

    var description: String {
        return title + ": " + message
    }
}
