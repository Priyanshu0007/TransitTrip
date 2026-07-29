//
//  TransitWidgetBundle.swift
//  TransitWidget
//
//  Created by Priyanshu Gupta on 26/07/26.
//

import WidgetKit
import SwiftUI

@main
struct TransitWidgetBundle: WidgetBundle {
    var body: some Widget {
        TransitWidgetLiveActivity()
        TransitWidget()
        if #available(iOS 18.0, *) {
            TransitWidgetControl()
        }
    }
}

