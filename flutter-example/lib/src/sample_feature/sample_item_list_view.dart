import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';

class JsonRpcWebView extends StatefulWidget {
  final Function(String) onMessageReceived;

  const JsonRpcWebView({Key? key, required this.onMessageReceived})
      : super(key: key);

  @override
  _JsonRpcWebViewState createState() => _JsonRpcWebViewState();
}

class _JsonRpcWebViewState extends State<JsonRpcWebView> {
  late final WebViewController _controller;
  DateTime? _webViewLoadStartTime;
  DateTime? _rpcRequestStartTime;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    _webViewLoadStartTime = DateTime.now(); // Start timing the WebView load
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            final loadDuration =
                DateTime.now().difference(_webViewLoadStartTime!);
            debugPrint(
                'Page finished loading: $url in ${loadDuration.inMilliseconds} ms');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
            ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              debugPrint('blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          if (_rpcRequestStartTime != null) {
           
          final rpcDuration = DateTime.now().difference(_rpcRequestStartTime!);
          debugPrint(
              'RPC response received in ${rpcDuration.inMilliseconds} ms');

          }
          widget.onMessageReceived(message.message);
        },
      );

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;
    _loadLocalHtml();
  }

  Future<void> _loadLocalHtml() async {
    final directory = await getApplicationDocumentsDirectory();
    final targetDir = Directory('${directory.path}/dock-sdk');

    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    final assetManifest = await rootBundle.loadString('AssetManifest.json');
    final assets = Map<String, dynamic>.from(json.decode(assetManifest));

    final List<String> files =
        assets.keys.where((key) => key.startsWith('assets/dock-sdk/')).toList();

    for (final asset in files) {
      final data = await rootBundle.load(asset);
      final bytes = data.buffer.asUint8List();
      final file = File('${targetDir.path}/${asset.split('/').last}');
      await file.writeAsBytes(bytes, flush: true);
    }

    final indexPath = '${targetDir.path}/index.html';
    _controller.loadFile(indexPath);
    // Every update made in the webivew code, requires a rebuild in the flutter app
    // To improve the development experience, you can load the webivew code from a local server
    // Uncomment the line below and replace the IP address with your local IP address
    // Make sure to run the local server before uncommenting the line below
    // _controller.loadRequest(Uri.parse("http://192.168.1.117:8080/index.html"));
  }

  String _generateJsonRpcRequest(
      String method, Map<String, dynamic> args, int id) {
    final request = {
      "type": "json-rpc-request",
      "body": {
        "jsonrpc": "2.0",
        "method": method,
        "params": {
          "__args": [args]
        },
        "id": id
      }
    };
    return jsonEncode(request);
  }

  void sendRpcMessage(String method, Map<String, dynamic> args, int id) {
    _rpcRequestStartTime = DateTime.now(); // Start timing the RPC request
    final jsonRpcRequest = _generateJsonRpcRequest(method, args, id);
    final script = 'window.postMessage(${jsonEncode(jsonRpcRequest)}, "*");';
    _controller.runJavaScript(script);
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}

class SampleItemListView extends StatefulWidget {
  const SampleItemListView({
    super.key,
    this.items = const [SampleItem(1), SampleItem(2), SampleItem(3)],
  });

  static const routeName = '/';

  final List<SampleItem> items;

  @override
  _SampleItemListViewState createState() => _SampleItemListViewState();
}

class _SampleItemListViewState extends State<SampleItemListView> {
  final GlobalKey<_JsonRpcWebViewState> _webViewKey =
      GlobalKey<_JsonRpcWebViewState>();
  String _rpcResponse = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sample Items'),
      ),
      body: Column(
        children: [
          Expanded(
            child: JsonRpcWebView(
              key: _webViewKey,
              onMessageReceived: (message) {
                setState(() {
                  _rpcResponse = message;
                });
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Operations with the dock-sdk
              // _webViewKey.currentState?.sendRpcMessage(
              //   "dock.init",
              //   {"address": "wss://knox-1.dock.io"},
              //   3,
              // );

              // _webViewKey.currentState?.sendRpcMessage(
              //   "keyring.initialize",
              //   {"ss58Format": 21},
              //   3,
              // );

              // call credential operation
              rootBundle
                  .loadString('assets/dock-sdk/template.json')
                  .then((jsonContent) {
                final template = jsonDecode(jsonContent);
                _webViewKey.currentState?.sendRpcMessage(
                  "credentials.deriveVCFromPresentation",
                  template,
                  // {
                  //   "proofRequest": template.,
                  //   "credentials": [
                  //     {
                  //       "credential": template.credential,
                  //       "witness":
                  //           "0x82e77125fc1204e31a09eed76422a81b9c81514f12db14eb95895cea95c596ad500a837765e459f93d779c027ecd24a8",
                  //       "attributesToReveal": [
                  //         "credentialSubject.id",
                  //         "credentialSubject.dateOfBirth",
                  //         "id",
                  //       ]
                  //     }
                  //   ]
                  // },
                  3,
                );
              });

              setState(() {
                _rpcResponse = 'Loading...';
              });
            },
            child: const Text('Send RPC Message'),
          ),
          Text('RPC Response: $_rpcResponse'),
        ],
      ),
    );
  }
}

class SampleItem {
  final int id;
  const SampleItem(this.id);
}
