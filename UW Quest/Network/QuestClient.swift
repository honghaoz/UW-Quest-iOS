//
//  QuestClient.swift
//  UW Quest
//
//  Created by Honghao Zhang on 2014-09-16.
//  Copyright (c) 2014 Honghao. All rights reserved.
//

import Foundation

let kUWQuestAPIKey: String = "77881122"
let kUWQuestAPIBaseURL: String = "http://uw-quest.appspot.com"

private let _sharedClient = QuestClient(baseURL: NSURL(string: kUWQuestAPIBaseURL))

class QuestClient: AFHTTPSessionManager {
    
    override init(baseURL url: NSURL!) {
        super.init(baseURL: url)
        setupSerializer()
    }
    
    override init(baseURL url: NSURL!, sessionConfiguration configuration: NSURLSessionConfiguration!) {
        super.init(baseURL: url, sessionConfiguration: configuration)
        setupSerializer()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSerializer()
    }
    
    func setupSerializer() {
        self.responseSerializer = AFJSONResponseSerializer()
        self.requestSerializer = AFHTTPRequestSerializer()
    }
    
    class var sharedClient: QuestClient {
        return _sharedClient
    }
    
    func login(username: String!, password: String!) {
        if username.isEmpty || password.isEmpty {
            Locator.sharedLocator.sharedHud.dismissAfterDelay(0.2)
            return
        }
        let path = "login"
        let parameters: Dictionary = [
            "userid": username,
            "password": password,
            "key": kUWQuestAPIKey
        ]
        println("Login: userid: \(username), password: \(password)")
        self.POST(path, parameters: parameters, success: { (task, responseObject) -> Void in
            println(responseObject)
            self.dismissHud()
        }) { (task, error) -> Void in
            println(error.localizedDescription)
            self.dismissHud()
        }
    }
    
    private func dismissHud() {
        Locator.sharedLocator.sharedHud.textLabel.text = ""
        Locator.sharedLocator.sharedHud.dismiss()
    }
}