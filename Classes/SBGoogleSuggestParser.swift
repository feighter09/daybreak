/*
SBGoogleSuggestParser.swift

Copyright (c) 2014, Alice Atlas
Copyright (c) 2010, Atsushi Jike
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import Foundation

let kSBGSToplevelTagName = "toplevel"
let kSBGSCompleteSuggestionTagName = "CompleteSuggestion"
let kSBGSSuggestionTagName = "suggestion"
let kSBGSNum_queriesTagName = "num_queries"
let kSBGSSuggestionAttributeDataArgumentName = "data"

class SBGoogleSuggestParser: NSObject, NSXMLParserDelegate {
    var items: [NSMutableDictionary] = []
    var _inToplevel = false
    var _inCompleteSuggestion = false
    
    class func parser() -> SBGoogleSuggestParser {
        return SBGoogleSuggestParser()
    }
    
    func parseData(data: NSData) -> NSError? {
        _inToplevel = false
        _inCompleteSuggestion = false
        let parser = NSXMLParser(data: data)
        parser.delegate = self
        parser.shouldProcessNamespaces = false
        parser.shouldReportNamespacePrefixes = false
        parser.shouldResolveExternalEntities = false
        items = []
        return parser.parse() ? nil : parser.parserError
    }
    
    // Delegate
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName: String?, attributes: NSDictionary) {
        if elementName == kSBGSToplevelTagName {
            _inToplevel = true
        } else if elementName == kSBGSCompleteSuggestionTagName {
            let item = NSMutableDictionary()
            _inCompleteSuggestion = true
            item[kSBType] = kSBURLFieldItemGoogleSuggestType
            items.append(item)
        } else {
            if _inToplevel && _inCompleteSuggestion {
                if elementName == kSBGSSuggestionTagName {
                    let dataText = attributes[kSBGSSuggestionAttributeDataArgumentName] as String
                    if dataText.utf16Count > 0 {
                        let item = items[items.count - 1]
                        item[kSBTitle] = dataText
                        item[kSBURL] = dataText.searchURLString
                    }
                }
            }
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName: String?) {
        if elementName == kSBGSToplevelTagName {
            _inToplevel = false
        } else if elementName == kSBGSCompleteSuggestionTagName {
            _inCompleteSuggestion = false
        }
    }
    
    func parser(parser: NSXMLParser, parseErrorOccurred error: NSError) {
        parser.abortParsing()
    }
    
    func parser(parser: NSXMLParser, validationErrorOccurred error: NSError) {
        parser.abortParsing()
    }
}