import 'package:get_it/get_it.dart';
import 'package:gps_maps/states/mqtt_wrapper.dart';

GetIt locator = GetIt.I;

void setupLocator() {
  locator.registerLazySingleton<MqttWrapper>(() => MqttWrapper());
}
