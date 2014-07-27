/*
SBDownloader.swift

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

class SBDownloader: NSObject {
    var url: NSURL
    var delegate: SBDownloaderDelegate?
    var connection: NSURLConnection?
    var receivedData: NSMutableData?
    
    init(URL url: NSURL) {
        self.url = url
    }
    
    class func downloadWithURL(url: NSURL) -> SBDownloader {
        return SBDownloader(URL: url)
    }
    
    // Delegate
    
    func connection(connection: NSURLConnection, willCacheResponse cachedResponse: NSCachedURLResponse) -> NSCachedURLResponse? {
        return nil
    }
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        var statusCode = 0
        if let resp = response as? NSHTTPURLResponse {
            statusCode = resp.statusCode
        }
        if statusCode != 200 {
            self.executeDidFail(nil)
            self.cancel()
        }
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        if receivedData == nil {
            receivedData = data.mutableCopy() as? NSMutableData
        } else {
            receivedData!.appendData(data)
        }
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        if receivedData?.length > 0 {
            self.executeDidFinish()
        } else {
            self.executeDidFail(nil)
        }
        self.destructConnection()
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        self.executeDidFail(error)
        self.destructConnection()
    }
    
    // Execute
    
    func executeDidFinish() {
        delegate?.downloader(self, didFinish: receivedData!.copy() as NSData) // ???(!)
    }
    
    func executeDidFail(error: NSError?) {
        delegate?.downloader?(self, didFail: error)
    }
    
    // Actions
    
    func destructConnection() {
        connection = nil
    }
    
    func destructReceivedData() {
        receivedData = nil
    }
    
    func start() {
        self.destructReceivedData()
        if url != nil {
            let request = NSURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: kSBTimeoutInterval)
            self.destructConnection()
            connection = NSURLConnection(request: request, delegate: self)
        }
    }
    
    func cancel() {
        self.connection?.cancel()
    }
}