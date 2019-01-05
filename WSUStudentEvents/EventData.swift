//
//  EventData.swift
//  WSUStudentEvents
//
//  Created by Colin Warn on 7/26/17.
//  Copyright © 2017 Colin Warn. All rights reserved.
//

import Foundation

struct EventData {
    var description = String()
    var endTime = String()
    var eventName = String()
    var eventType = String()
    var location = String()
    var password: String = ""
    var startTime: String = ""
    var whosGoing: [String] = []
}
