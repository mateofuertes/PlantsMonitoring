# Orchid Monitoring Module with Vision-Based Object Detection and Mobile Interface

## Overview

This module is designed with the objective of performing a review of the progress of orchids, as well as the detection of certain states of the plant using an Object Detection Model. After image capture and object detection using an Arduino Nicla Vision, the image is sent to a server running on a Raspberry Pi. Finally, in order to analyse the images, there is a mobile application that allows the user to view or download the images through a intuitive graphical interface.


## Components

- **Arduino® Nicla Vision:**

The Nicla Vision camera is used for image capture and processing via FOMO MobileNetV2 0.35. Two processes are carried out, the first is a periodic capture of photos in order to be able to analyse the growth progress of the plant. The second one is a constant image capture in order to detect various stages of the plant. In both cases, the object detection model is used.

- **Raspberry Pi:**

A Raspberry Pi 3 Model V1.2 was used to set up a server with an API service that allows communication with the other components. That is, to store the images captured by the Nicla Vision and allow them to be visualised through the mobile application.

- **Android Mobile App:**

A mobile application was designed using Flutter Dart. In it you can see the images taken daily to analyse the progress, as well as the detections obtained on different days. In addition, all images can be downloaded, or a specific range can be selected for download.

## Installation

1. **Configure Raspberry Pi Server:**
    The project was intended to be deployed in an environment without internet access. Therefore, once the Raspberry Pi operating system is installed, it is     
    necessary to configure an access point on the Raspberry Pi (You need a model with this function or have a component that allows this function). In the tests of 
    this system, RaspAp was used. Copy the file api.py avaiable in the folder /src/Raspberry Pi Server. Execute it using python3 api.py. It is recommended to set 
    up a service with systemd so that the server runs whenever the raspberry pi is turned on.
   
2. **Download Mobile Application:**
    Download and install the apk on a phone with an Android operating system. Open the application and enter the ip of the raspberry pi. If the raspberry pi is not 
    connected to the internet, and you have configured an access point on it; you need to be connected to this AP. Once this is done, it is important to 
    go to the calendar screen and tap on the Synchronize Date button.
   
3. **Configure Nicla Vision:**
    Connect the Nicla Vision using a USB cable. Go to the Nicla Vision's memory and copy the three files present in "/src/Nicla Vision Code/" i.e. labels.txt,      
    main.py, trained.tflite. When you connect the Nicla Vision to a power source, the main.py file should run automatically.
