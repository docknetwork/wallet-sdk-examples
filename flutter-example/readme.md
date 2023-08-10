# Flutter Example
To integrate the wallet-sdk in your Flutter app, you'll need to create a JavaScript bundle and load it inside a WebView. Here are the steps to achieve that:

Add the webview_flutter package to your pubspec.yaml file and run flutter pub get to install it:

```yaml
dependencies:
  flutter:
    sdk: flutter
    assets:
        - assets/wallet-sdk.js
        - assets/wallet-sdk.html
  webview_flutter: ^2.0.14 # Use the latest version available at the time
```

Import the necessary packages in your Flutter app:

```dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
```

Create a WebView and enable communication between the WebView and the Flutter app:

``` dart
class MyWebView extends StatefulWidget {
  @override
  _MyWebViewState createState() => _MyWebViewState();
}


class _MyWebViewState extends State<MyWebView> {
  WebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dock SDK Example'),
      ),
      body: WebView(
        initialUrl: 'file:///android_asset/flutter_assets/assets/wallet-sdk.html',
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (controller) {
          _webViewController = controller;
          _setupJavascriptChannel();
        },
      ),
    );
  }

  void _setupJavascriptChannel() {
    _webViewController.addJavascriptChannel(
      JavascriptChannel(
        name: 'flutterBridge', // This is the name of the channel to use in JavaScript
        onMessageReceived: (JavascriptMessage message) {
          // Handle the message received from JavaScript
          // You can use the data passed in the message argument
          print('Received message from JavaScript: ${message.message}');
          // You can perform any actions here based on the received message
        },
      ),
    );
  }

  // Function to send messages from Flutter to JavaScript
  Future<void> _sendToJavaScript(String message) async {
    await _webViewController.evaluateJavascript("receiveMessage('$message')");
  }
}
```

In the HTML/JavaScript code within the WebView, you need to have the function that receives messages from the Flutter app. For example:

```bash
yarn install
yarn build

## copy the .js and .html files from the public folder to the assets folder
```

Now you have set up a Flutter WebView that allows communication between the Flutter app and the JavaScript code running inside the WebView. You can use _sendToJavaScript in Flutter to send messages, and the JavaScript function receiveMessage inside the WebView to handle those messages.

