# SnapchatDetailsTransition


SnapchatDetailsTransition is a SwiftUI app that demonstrates a zoom transition to a details screen and drag-to-dismiss functionality, similar to the Snapchat app. This app utilizes the **`matchedGeometryEffect`** to achieve a seamless and visually appealing transition between screens.

## Features
Zoom transition to details screen: When a user taps on an item in the main screen, the app smoothly transitions to a details screen, providing a zoom effect to focus on the selected item.

Drag-to-dismiss: In the details screen, the user can drag the screen downwards to dismiss it and return to the main screen. The app provides an interactive and intuitive user experience, similar to the Snapchat app.

## Requirements

- iOS 16.0+
Xcode 14.3+
Swift 5.0+

## Installation

1. Clone the repository:
```bash
git clone https://github.com/SwiftLogic/SnapchatDetailsTransition.git
```
2. Open the project in Xcode.

3. Build and run the app on a simulator or physical device.


## Implementation Details

The app is built using SwiftUI, The main screen displays a list of items using SwiftUI's VStack embedded in a ScrollView. When an item is tapped, the app transitions to the details screen, where the selected item is displayed.

To achieve the zoom effect, the **`matchedGeometryEffect`** modifier is used in combination with a custom transition. The **`matchedGeometryEffect`** ensures that the selected item smoothly transitions between the main screen and the details screen, while the custom transition provides the zoom effect.

For the drag-to-dismiss functionality, the DragGesture is utilized. When the user drags the details screen downwards, the app detects the gesture and initiates the dismissal animation, returning the user to the main screen.


