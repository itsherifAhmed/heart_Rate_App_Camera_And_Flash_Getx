import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:wakelock/wakelock.dart';
import '../model/sensor.dart';


class HomeController extends GetxController with SingleGetTickerProviderMixin{
  List<SensorValue> data = []; // array to store the values
  int bpm = 0; // beats per minute
  int fs = 30; // sampling frequency (fps)


  bool toggled = false; // toggle button value
  CameraController camera_controller;
  RxDouble alpha = 0.3.obs; // factor for the mean value
  AnimationController animationController;
  double iconScale = 1;
  int windowLen = 30 * 6; // window length to display - 6 seconds
  CameraImage canera_image; // store the last camera image
  double avg; // store the average value during calculation
  DateTime now; // store the now Datetime
  Timer timer; // timer for image processing
@override
  void onInit() {
  animationController =
      AnimationController(duration: Duration(milliseconds: 500),
          vsync: this);
  animationController
    .addListener(() {

        iconScale = 1.0 + animationController.value * 0.4;

    });
    super.onInit();
  }
  @override
  void dispose() {
    timer.cancel();
    toggled = false;
    disposeController();
    Wakelock.disable();
    animationController?.stop();
    animationController?.dispose();    super.dispose();
  }

  void clearData() {
    // create array of 128 ~= 255/2
    data.clear();
    int now = DateTime.now().millisecondsSinceEpoch;
    for (int i = 0; i < windowLen; i++) {
      data.insert(
          0,
          SensorValue(
              DateTime.fromMillisecondsSinceEpoch(now - i * 1000 ~/ fs), 128));
    }
    update();
  }
  void toggle() {
    clearData();
    initController().then((onValue) {
      Wakelock.enable();
      animationController.repeat(reverse: true);

        toggled = true;

      // after is toggled
      initTimer();
      updateBPM();
    });
    update();
  }
  void untoggle() {
    disposeController();
    Wakelock.disable();
    animationController.stop();
    animationController?.value = 0.0;

      toggled = false;
    update();
  }
  void disposeController() {
    camera_controller.dispose();
    camera_controller = null;
    update();
  }

  Future<void> initController() async {
    try {
      List _cameras = await availableCameras();
      camera_controller = CameraController(_cameras.first, ResolutionPreset.low);
      await camera_controller.initialize();
      Future.delayed(const Duration(milliseconds: 100)).then((onValue) {
        camera_controller.setFlashMode(FlashMode.torch);
      });
      camera_controller.startImageStream((CameraImage image) {
        canera_image = image;
      });
    } on Exception {
      if (kDebugMode) {
        print(Exception);
      }
    }
    update();
  }

  void initTimer() {
    timer = Timer.periodic(Duration(milliseconds: 1000 ~/ fs),
            (timer) {
      if (toggled) {
        if (canera_image != null) scanImage(canera_image);
      } else {
        timer.cancel();
      }
    });
    update();
  }


  void scanImage(CameraImage image) {
    now = DateTime.now();
    avg =
        image.planes.first.bytes.reduce
          ((value, element) => value + element) /
            image.planes.first.bytes.length;
    if (data.length >= windowLen) {
      data.removeAt(0);
    }
      data.add(SensorValue(now, 255 - avg));
    update();
  }
  void updateBPM() async {
    // Bear in mind that the method used to calculate the BPM is very rudimentar
    // feel free to improve it :)

    // Since this function doesn't need to be so "exact" regarding the time it executes,
    // I only used the a Future.delay to repeat it from time to time.
    // Ofc you can also use a Timer object to time the callback of this function
    List<SensorValue> _values;
    double _avg;
    int _n;
    double _m;
    double _threshold;
    double _bpm;
    int _counter;
    int _previous;
    while (toggled) {
      _values = List.from(data); // create a copy of the current data array
      _avg = 0;
      _n = _values.length;
      _m = 0;
      _values.forEach((SensorValue value) {
        _avg += value.value / _n;
        if (value.value > _m) _m = value.value;
      });


      _threshold = (_m + _avg) / 2;
      _bpm = 0;
      _counter = 0;
      _previous = 0;
      for (int i = 1; i < _n; i++) {
        if (_values[i - 1].value < _threshold &&
            _values[i].value > _threshold) {
          if (_previous != 0) {
            _counter++;
            _bpm += 60 *
                1000 /
                (_values[i].time.millisecondsSinceEpoch - _previous);
          }
          _previous = _values[i].time.millisecondsSinceEpoch;
        }
      }
      if (_counter > 0) {
        _bpm = _bpm / _counter;
        if (kDebugMode) {
          print("$_bpm here your bpm");
        }
          bpm = _bpm.toInt();
      }
      await Future.delayed(Duration(
          milliseconds:
          1000 * windowLen ~/ fs)); // wait for a new set of _data values
    }
    update();
  }


}