//
//  PocketsWidgetLiveActivity.swift
//  PocketsWidget
//
//  Created by Wen Cheng on 7/1/2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct PocketsWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct PocketsWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PocketsWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension PocketsWidgetAttributes {
    fileprivate static var preview: PocketsWidgetAttributes {
        PocketsWidgetAttributes(name: "World")
    }
}

extension PocketsWidgetAttributes.ContentState {
    fileprivate static var smiley: PocketsWidgetAttributes.ContentState {
        PocketsWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: PocketsWidgetAttributes.ContentState {
         PocketsWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: PocketsWidgetAttributes.preview) {
   PocketsWidgetLiveActivity()
} contentStates: {
    PocketsWidgetAttributes.ContentState.smiley
    PocketsWidgetAttributes.ContentState.starEyes
}
