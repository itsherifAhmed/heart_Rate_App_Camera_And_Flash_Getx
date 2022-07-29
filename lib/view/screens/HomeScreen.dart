import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heartrate/controller/HomeController.dart';

import '../widget/chart.dart';

class HomeScreen extends StatelessWidget {
  //HomeController controller = Get.put(HomeController());


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: GetBuilder<HomeController>(
              init: HomeController(),
              builder: (controller) {
            return Column(
              children: <Widget>[
                Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(18),
                              ),
                              child: Stack(
                                fit: StackFit.expand,
                                alignment: Alignment.center,
                                children: <Widget>[
                                  controller.camera_controller != null &&
                                      controller.toggled
                                      ? AspectRatio(
                                    aspectRatio:
                                    controller.camera_controller.value
                                        .aspectRatio,
                                    child: CameraPreview(
                                        controller.camera_controller),
                                  )
                                      : Container(
                                    padding: const EdgeInsets.all(12),
                                    alignment: Alignment.center,
                                    color: Colors.grey,
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.all(4),
                                    child: Text(
                                      controller.toggled
                                          ? "Cover both the camera and the flash with your finger"
                                          : "Camera feed will display here",
                                      style: TextStyle(
                                          backgroundColor: controller.toggled
                                              ? Colors.white
                                              : Colors.transparent),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  const Text(
                                    "Estimated BPM",
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.grey),
                                  ),
                                  Text(
                                    (controller.bpm > 30 &&
                                        controller.bpm < 150 ? controller
                                        .bpm.toString() : "--"),
                                    style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )),
                        ),
                      ],
                    )),

                Expanded(
                  flex: 1,
                  child: Center(
                    child: Transform.scale(
                      scale: controller.iconScale,
                      child: IconButton(
                        icon:
                        Icon(controller.toggled ? Icons.favorite : Icons
                            .favorite_border),
                        color: Colors.red,
                        iconSize: 128,
                        onPressed: () {
                          if (controller.toggled) {
                            controller.untoggle();
                          } else {
                            controller.toggle();
                          }
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(18),
                        ),
                        color: Colors.black),
                    child: Chart(controller.data),
                  ),
                ),
              ],
            );
          })
      ),
    );
  }

}
