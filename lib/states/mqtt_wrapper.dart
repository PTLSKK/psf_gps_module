import 'package:mqtt_client/mqtt_client.dart';

class MqttWrapper {
  String broker = 'ec2-54-255-192-5.ap-southeast-1.compute.amazonaws.com';

  MqttClient client;
  String clientIdentifier;

  MqttWrapper() {
    clientIdentifier = "tracker-gps-${DateTime.now().toString()}";
  }

  void prepareMqttClient() async {
    _setupMqttClient();
    await _connectClient();
  }

  Future<void> _connectClient() async {
    try {
      print('MQTTClientWrapper::Mosquitto client connecting....');
      await client.connect();
    } on Exception catch (e) {
      print('MQTTClientWrapper::client exception - $e');
      client.disconnect();
    }

    if (client.connectionStatus.state == MqttConnectionState.connected) {
      print('MQTTClientWrapper::Mosquitto client connected');
    } else {
      print(
          'MQTTClientWrapper::ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
      client.disconnect();
    }
  }

  void _setupMqttClient() {
    client = MqttClient.withPort(broker, clientIdentifier, 5883);
    client.logging(on: false);
    client.keepAlivePeriod = 20;
    client.onDisconnected = _onDisconnected;
    client.onConnected = _onConnected;
    client.onSubscribed = _onSubscribed;
  }

  void _subscribeToTopic(String topicName) {
    print('MQTTClientWrapper::Subscribing to the $topicName topic');
    client.subscribe(topicName, MqttQos.atMostOnce);
  }

  void publishMessage(String topic, String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);

    print('MQTTClientWrapper::Publishing message $message to topic $topic');
    client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload);
  }

  void _onSubscribed(String topic) {
    print('MQTTClientWrapper::Subscription confirmed for topic $topic');
  }

  Future<void> _onDisconnected() async {
    print(
        'MQTTClientWrapper::OnDisconnected client callback - Client disconnection');
    if (client.connectionStatus.returnCode == MqttConnectReturnCode.solicited) {
      print(
          'MQTTClientWrapper::OnDisconnected callback is solicited, this is correct');
    } else {
      await reconnect();
    }
  }

  void _onConnected() {
    print(
        'MQTTClientWrapper::OnConnected client callback - Client connection was sucessful');
  }

  Future reconnect() async {
    while (client.connectionStatus.state != MqttConnectionState.connected) {
      await _connectClient();
      await MqttUtilities.asyncSleep(2);
    }
  }
}
