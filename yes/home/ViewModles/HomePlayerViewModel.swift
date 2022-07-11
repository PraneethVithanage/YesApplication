//
//  HomePlayerViewModel.swift
//  yes
//
//  Created by Erandra Jayasundara on 2021-07-12.
//

import Foundation

class HomePlayerViewModel: ObservableObject {
    
    @Published var currentSongTitle: String = ""
    @Published var currentSongArtist: String = ""
    @Published var liveProgram: LiveProgram?
    @Published var channelPrograms: ChannelPrograms?
    @Published var studioData: [String] = []

    init() {
        getCurrentSong()
        getLiveProgram()
        getChannelProgramList()
        getMstudioData()
    }
    func getCurrentSong() {
        let param = [
            "accessToken" : "@aCCess$321tOKeN@987",
            "channelId" : "4",
            "languageId" : "2",
            "userId" : "0"
        ]
        URLSession.fetch(request: URLRequest.get(method: "GetCurrentSong", data: param), completion: { resp in
            
            switch resp {
            case .success(let code):
                if let json = try? JSONSerialization.jsonObject(with: code.data(using: .utf8)!) as? [String: Any] {
                    
                    if let consolePlayListItems = json["ConsolePlayListItems"] as? [[String: Any]] {
                        
                        DispatchQueue.main.async {
                            if let artistInfo = consolePlayListItems[0]["ArtistInfo"] as? [String : Any] {
                                //self.currentSongArtist = artistInfo["ArtistName"] as? String ?? ""
                            }
                         //   self.currentSongTitle = consolePlayListItems[0]["Title"] as? String ?? ""
                        }
                    }
                }
                
                
            case .failure(_):
                print("Error")
                
            }
        })
    }
    
    func getLiveProgram() {
        let param = [
            "accessToken" : "@aCCess$321tOKeN@987",
            "channelId" : "4",
            "languageId" : "2",
            "userId" : "0"
        ]
        URLSession.fetch(request: URLRequest.get(method: "GetLiveProgramInfo", data: param), completion: { resp in
            switch resp {
            case .success(let result):
                
                DispatchQueue.main.async {
                    self.liveProgram = try? JSONDecoder().decode(LiveProgram.self, from: result.data(using: .utf8)!)
                }
               
            case .failure(_):
                print("Error")
                
            }
        })
    }
    
    func getChannelProgramList() {
        let param = [
            "accessToken" : "@aCCess$321tOKeN@987",
            "channelId" : "4",
            "languageId" : "2",
            "userId" : "0"
        ]
        URLSession.fetch(request: URLRequest.get(method: "GetChannelProgramList", data: param), completion: { resp in
            switch resp {
                
            case .success(let result):
                if let data = result.data(using: .utf8){
                    do {
                        let decodedResponse = try JSONDecoder().decode(ChannelPrograms.self, from: data)
                        DispatchQueue.main.async {
                            self.channelPrograms = decodedResponse
                        }
                    } catch let jsonError as NSError {
                        print("JSON decode failed: \(jsonError.localizedDescription)")
                    }
                    return
                }
                
            case .failure(_):
                print("Error")
                
            }
        })
    }
    
    func getMstudioData() {
        
        URLSession.fetch(request: URLRequest.getFormMstudio(), completion: { resp in
            switch resp {
                
            case .success(let result):
                // XML convert to array
                let summary = result
                let str = summary.replacingOccurrences(of: "<[^>]+>", with: ",", options: .regularExpression, range: nil)
                let Ttr = str.replacingOccurrences(of: "\r\n", with: "", options: .regularExpression, range: nil).replacingOccurrences(of: " ", with: "")
                let Ktr = Ttr.replacingOccurrences(of: ",,", with: ",", options: .regularExpression, range: nil).replacingOccurrences(of: " ", with: "")
                let array = Ktr.components(separatedBy: ",")
                
                DispatchQueue.main.async {
                    if array[2] != "N/A" && array[3] != "N/A" {
                        self.currentSongTitle = array[2]
                        self.currentSongArtist = array[3]
                    } else {
                        self.currentSongTitle = array[11]
                        self.currentSongArtist = array[12]
                    }
                }
                
                
            case .failure(_):
                print("Error")
                
            }
        })
    }
    
}



extension String{

    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }

    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
