//
//  CustomString.swift
//  TODO-LIST
//
//  Created by Raghavendra Shedole on 20/02/18.
//  Copyright © 2018 Raghavendra Shedole. All rights reserved.
//

import Foundation


extension NSDate {
    
    func showDate() ->String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a, dd MMM"
        return formatter.string(from: self as Date)
    }
}
