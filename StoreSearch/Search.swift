//
//  Search.swift
//  StoreSearch
//
//  Created by usuario on 13/10/15.
//  Copyright © 2015 Insoftcan. All rights reserved.
//

import Foundation

typealias SearchComplete = (Bool) -> Void

class Search {
    var searchResults = [SearchResult]()
    var hasSearched = false
    var isLoading = false
    
    private var dataTask: NSURLSessionDataTask? = nil
    
    func performSearchForText(text: String, category: Int, completion: SearchComplete) {
        if !text.isEmpty {
            dataTask?.cancel()
            
            isLoading = true
            hasSearched = true
            searchResults = [SearchResult]()
            
            let url = urlWithSearchText(text, category: category)
            
            let session = NSURLSession.sharedSession()
            dataTask = session.dataTaskWithURL(url, completionHandler: {
                data, response, error in
                
                var success = false
                
                if let error = error {
                    if error.code == -999 { return }    // Search was cancelled
                } else if let httpResponse = response as? NSHTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        if let dictionary = self.parseJSON(data!) {
                            self.searchResults = self.parseDictionary(dictionary)
                            self.searchResults.sort(<)
                            
                            self.isLoading = false
                            success = true
                        }
                    }
                }
                
                if !success {
                    self.hasSearched = false
                    self.isLoading   = false
                }

                dispatch_async(dispatch_get_main_queue()) {
                    completion(success)
                }
            })
            
            dataTask?.resume()
        }
    }
    
    private func urlWithSearchText(searchText: String, category: Int) -> NSURL {
        
        var entityName: String
        switch category {
        case 1: entityName = "musicTrack"
        case 2: entityName = "software"
        case 3: entityName = "ebook"
        default: entityName = ""
        }
        
        let escapedSearchText = searchText.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
        
        let urlString = String(format: "http://itunes.apple.com/search?term=%@&limit=200&entity=%@", escapedSearchText, entityName)
        let url = NSURL(string: urlString)
        return url!
    }
    
    private func parseJSON(data: NSData) -> [String: AnyObject]? {
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions(rawValue: 0) ) as! [String: AnyObject]
            return json
        } catch {
            print("Unknown JSON Error")
        }
        
        return nil
    }
    
    private func parseDictionary(dictionary: [String: AnyObject]) -> [SearchResult] {
        var searchResults = [SearchResult]()
        
        if let array: AnyObject = dictionary["results"] {
            for resultDict in array as! [AnyObject] {
                if let resultDict = resultDict as? [String: AnyObject] {
                    var searchResult: SearchResult?
                    
                    if let wrapperType = resultDict["wrapperType"] as? NSString {
                        switch wrapperType {
                        case "track":
                            searchResult = parseTrack(resultDict)
                        case "audiobook":
                            searchResult = parseAudioBook(resultDict)
                        case "software":
                            searchResult = parseSoftware(resultDict)
                        default:
                            break
                        }
                    } else if let kind = resultDict["kind"] as? NSString {
                        if kind == "ebook" {
                            searchResult = parseEBook(resultDict)
                        }
                    }
                    
                    if let result = searchResult {
                        searchResults.append(result)
                    }
                    
                } else {
                    print("Expected a dictionary")
                }
            }
        } else {
            print("Expected 'results' array")
        }
        
        return searchResults
    }
    
    private func parseTrack(dictionary: [String: AnyObject]) -> SearchResult {
        let searchResult = SearchResult()
        
        searchResult.name = dictionary["trackName"] as! NSString as String
        searchResult.artistName = dictionary["artistName"] as! NSString as String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! NSString as String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! NSString as String
        searchResult.storeURL = dictionary["trackViewUrl"] as! NSString as String
        searchResult.kind = dictionary["kind"] as! NSString as String
        searchResult.currency = dictionary["currency"] as! NSString as String
        
        if let price = dictionary["trackPrice"] as? NSNumber {
            searchResult.price = Double(price)
        }
        if let genre = dictionary["primaryGenreName"] as? NSString {
            searchResult.genre = genre as String
        }
        
        return searchResult
    }
    
    private func parseAudioBook(dictionary: [String: AnyObject]) -> SearchResult {
        let searchResult = SearchResult()
        
        searchResult.name           = dictionary["collectionName"] as! String
        searchResult.artistName     = dictionary["artistName"] as! String
        searchResult.artworkURL60   = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100  = dictionary["artworkUrl100"] as! String
        searchResult.storeURL       = dictionary["collectionViewUrl"] as! String
        searchResult.kind           = "audiobook"
        searchResult.currency       = dictionary["currency"] as! String
        if let price = dictionary["collectionPrice"] as? NSNumber {
            searchResult.price      = Double(price)
        }
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre      = genre
        }
        
        return searchResult
    }
    
    private func parseSoftware(dictionary: [String: AnyObject]) -> SearchResult {
        let searchResult = SearchResult()
        
        searchResult.name           = dictionary["trackName"] as! String
        searchResult.artistName     = dictionary["artistName"] as! String
        searchResult.artworkURL60   = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100  = dictionary["artworkUrl100"] as! String
        searchResult.storeURL       = dictionary["trackViewUrl"] as! String
        searchResult.kind           = dictionary["kind"] as! String
        searchResult.currency       = dictionary["currency"] as! String
        if let price = dictionary["price"] as? NSNumber {
            searchResult.price      = Double(price)
        }
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre      = genre
        }
        
        return searchResult
    }
    
    private func parseEBook(dictionary: [String: AnyObject]) -> SearchResult {
        let searchResult = SearchResult()
        
        searchResult.name           = dictionary["trackName"] as! String
        searchResult.artistName     = dictionary["artistName"] as! String
        searchResult.artworkURL60   = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100  = dictionary["artworkUrl100"] as! String
        searchResult.storeURL       = dictionary["trackViewUrl"] as! String
        searchResult.kind           = dictionary["kind"] as! String
        searchResult.currency       = dictionary["currency"] as! String
        if let price = dictionary["price"] as? NSNumber {
            searchResult.price      = Double(price)
        }
        if let genres: AnyObject = dictionary["genres"] {
            //            searchResult.genre      = ", ".join(genres as! [String])
            searchResult.genre = (genres as! [String]).joinWithSeparator(", ")
        }
        
        return searchResult
    }
}
