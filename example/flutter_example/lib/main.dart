import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarsier_websocket_client/tarsier_websocket_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Laravel Pusher Client'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  final _hostController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _clusterController = TextEditingController();
  final _publicChannelController = TextEditingController();
  final _publicEventController = TextEditingController();
  //final _privateChannelController = TextEditingController();
  //final _privateEventController = TextEditingController();
  final _scrollController = ScrollController();
  final _dataController = TextEditingController();
  final _hostFormKey = GlobalKey<FormState>();
  final _publicChannelFormKey = GlobalKey<FormState>();
  final _privateChannelFormKey = GlobalKey<FormState>();

  List<bool> selectionLogList = [true, false, false];
  String status = 'DISCONNECTED';
  String _publicLog = 'output:\n';
  //String _privateLog = 'output:\n';

  PusherClient? pusher;
  Channel? publicChannel;
  Channel? privateChannel;

  void logData(String text) {
    setState(() {
      String separator = "*" * 100;
      _publicLog += "$text\n$separator\n";
      Timer(
          const Duration(milliseconds: 100),
          () => _scrollController
              .jumpTo(_scrollController.position.maxScrollExtent));
    });
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

// Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _hostController.text =
          prefs.getString("host_pushier_client") ?? '192.168.10.121';
      _apiKeyController.text =
          prefs.getString("apiKey_pushier_client") ?? '182c58278217ab48deab';
      _clusterController.text =
          prefs.getString("cluster_pushier_client") ?? 'mt1';
      _publicChannelController.text =
          prefs.getString("channelName_pushier_client") ?? 'message-channel';
      _publicEventController.text =
          prefs.getString("eventName_pushier_client") ?? 'message-event';
      _dataController.text = prefs.getString("data_pushier_client") ?? 'test';
    });
  }

  Future<void> connectServer() async {
    if (!_hostFormKey.currentState!.validate()) {
      return;
    }
    // Remove keyboard
    FocusScope.of(context).requestFocus(FocusNode());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("host_pushier_client", _hostController.text);
    prefs.setString("apiKey_pushier_client", _apiKeyController.text);
    prefs.setString("cluster_pushier_client", _clusterController.text);
    prefs.setString(
        "channelName_pushier_client", _publicChannelController.text);
    prefs.setString("eventName_pushier_client", _publicEventController.text);

    String token = '';
    PusherOptions options = PusherOptions(
        key: _apiKeyController.text,
        host: _hostController.text,
        wsPort: 6001,
        encrypted: false,
        cluster: _clusterController.text,
        auth: PusherAuthOptions(
          "${_hostController.text}/broadcasting/auth",
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          },
        ),
        enableLogging: false);

    pusher = PusherClient(options: options);
    // Log event when there's an error on connection
    pusher!.onConnectionError((error) {
      printVerbose("Connection error", error!);
    });
    pusher!.onError((error) {
      printVerbose("Error", error);
    });
    pusher!.onDisconnected((data) {
      printVerbose("Disconnected: ", data);
    });

    // connect at a later time than at instantiation.
    if (status != 'DISCONNECTED') {
      pusher!.unsubscribe(_publicChannelController.text);
      pusher!.disconnect();
    }
    pusher!.connect();

    pusher!.onConnectionStateChange((state) {
      status = state.currentState!;
      printLog(
          tag: 'SocketConnectionState',
          message:
              "previousState: ${state.previousState}, currentState: ${state.currentState}");
    });

    pusher!.onConnectionError((error) {
      logData("🔴 ERROR: ${error!.message},${error!.exception} ");
    });

    publicChannel = pusher!.subscribe(_publicChannelController.text);

    publicChannel!.bind(_publicEventController.text, (event) {
      logData('Ⓜ️ ${event!.data!}');
    });
    publicChannel!.onSubscriptionSuccess((event) {
      printSuccess("pusher:subscription_succeeded", event ?? '');
    });
    publicChannel!.onInternalSubscriptionSuccess((event) {
      printSuccess("pusher_internal:subscription_succeeded", event ?? '');
    });

/*
    triggeredChannel = pusher.subscribe("private-device-channel");
    channel.bind("private-device-event", (event) {
      logData("private-device-event: ${event!.data!}");
    });
 */
  }

  Future<void> triggerEvent() async {
    var eventFormValidated = _privateChannelFormKey.currentState!.validate();

    if (!eventFormValidated) {
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("eventName_pushier_client", _publicEventController.text);
    prefs.setString("data_pushier_client", _dataController.text);

    //privateChannel!.trigger("private-device-event", {"message": _dataController.text});
  }

  Future<void> clearOutput() async {
    setState(() {
      _publicLog = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: status == 'CONNECTED'
                        ? Colors.green
                        : Colors.red, // border color
                    shape: BoxShape.circle,
                  ),
                  child: Container(),
                ),
                const SizedBox(width: 8),
                Text(
                  status,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: status == 'CONNECTED' ? Colors.green : Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            Form(
              key: _hostFormKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _hostController,
                    validator: (String? value) {
                      return (value != null && value.isEmpty)
                          ? 'Please enter your hostname.'
                          : null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Host',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _apiKeyController,
                    validator: (String? value) {
                      return (value != null && value.isEmpty)
                          ? 'Please enter your API key.'
                          : null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'API Key',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _clusterController,
                    validator: (String? value) {
                      return (value != null && value.isEmpty)
                          ? 'Please enter your cluster.'
                          : null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Cluster',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      const Spacer(),
                      SizedBox(
                        width: 120,
                        child: ElevatedButton(
                          onPressed: connectServer,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: status == 'CONNECTED'
                                  ? Colors.red
                                  : Colors.green),
                          child: Text(
                            status == 'CONNECTED' ? 'Disconnect' : 'Connect',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Form(
              key: _publicChannelFormKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _publicChannelController,
                    validator: (String? value) {
                      return (value != null && value.isEmpty)
                          ? 'Please enter your channel name.'
                          : null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Public Channel',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _publicEventController,
                    validator: (String? value) {
                      return (value != null && value.isEmpty)
                          ? 'Please enter your event name.'
                          : null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Public Event',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      const Spacer(),
                      SizedBox(
                        width: 120,
                        child: ElevatedButton(
                          onPressed: connectServer,
                          child: const Text('Subscribe'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            /*
            Form(
              key: _privateChannelFormKey,
              child: Column(children: <Widget>[
                TextFormField(
                  controller: _privateChannelController,
                  validator: (String? value) {
                    return (value != null && value.isEmpty) ? 'Please enter your channel name.' : null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Private Channel',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _privateEventController,
                  validator: (String? value) {
                    return (value != null && value.isEmpty) ? 'Please enter your event name.' : null;
                  },
                  decoration: const InputDecoration(
                    isDense: true,
                    labelText: 'Private Event',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Spacer(),
                    SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        onPressed: connectServer,
                        child: const Text('Subscribe'),
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  controller: _dataController,
                  decoration: const InputDecoration(
                    labelText: 'Private Data',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                Row(
                  children: [
                    Spacer(),
                    SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        onPressed: triggerEvent,
                        child: const Text('Trigger Event'),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    ToggleButtons(
                      onPressed: (int index) {
                        setState(() {
                          for (int i = 0; i < selectionLogList.length; i++) {
                            if (i == index) {
                              selectionLogList[i] = true;
                            } else {
                              selectionLogList[i] = false;
                            }
                          }
                        });
                      },
                      isSelected: selectionLogList,
                      children: const <Widget>[
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(Icons.public),
                              Text('Public Logs'),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(Icons.public_off),
                              Text('Private Logs'),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(Icons.co_present),
                              Text('Presence Logs'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        onPressed: clearOutput,
                        child: const Text('Clear Output'),
                      ),
                    ),
                  ],
                )
              ]),
            ),
            */
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blue,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(4),
                  ),
                ),
                width: double.infinity,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Text(
                    _publicLog,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
