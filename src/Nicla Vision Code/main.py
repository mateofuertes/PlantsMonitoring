import network
import urequests
import sensor
import image
import time
import io
import os, tf, math, uos, gc
import omv

# Configuration
ssid = 'plantsAccesPoint'
password = 'ChangeMe'
api_url = 'http://10.3.141.1:5000/upload'
model = 'trained.tflite'
labels_file = 'labels.txt'
min_confidence = 0.70
frecuency = 1
delta = 86400
colors = [(255, 0, 0), (0, 255, 0), (0, 0, 255)]
desired_labels = ['State 1', 'State 2', 'State 3', 'Orchidaceae']

def load_model(model, labels_file):
    global net, labels
    try:
        net = tf.load(model, load_to_fb=uos.stat(model)[6] > (gc.mem_free() - (64*1024)))
    except Exception as e:
        raise Exception(f'Failed to load {model} (' + str(e) + ')')
    try:
        labels = [line.rstrip('\n') for line in open(labels_file)]
    except Exception as e:
        raise Exception(f'Failed to load {labels_file} (' + str(e) + ')')
    omv.disable_fb(True)

def connect_wifi(ssid, password):
    try:
        wlan = network.WLAN(network.STA_IF)
        wlan.active(True)
        wlan.connect(ssid, password)
        while not wlan.isconnected():
            time.sleep(1)
            print("Connecting to WiFi...")
        print("Connected to WiFi:", wlan.ifconfig())
    except Exception as e:
        print(f"Error trying to connect to Wifi: {e}")

def capture_image():
    try:
        img = sensor.snapshot()
        return img
    except Exception as e:
        print(f"Error capturing the image: {e}")
        return 0

def process_image(img):
    try:
        detection_results = []
        for i, detection_list in enumerate(net.detect(img,
                                        thresholds=[(math.ceil(min_confidence * 255), 255)])):
            if i == 0: continue
            if len(detection_list) == 0: continue
            for d in detection_list:
                [x, y, w, h] = d.rect()
                center_x = math.floor(x + (w / 2))
                center_y = math.floor(y + (h / 2))
                img.draw_circle((center_x, center_y, 12), color=colors[i % len(colors)], thickness=2)
                detection_results.append((labels[i], (x, y, w, h)))
        return img, detection_results
    except Exception as e:
        print(f"Error processing image: {e}")

def upload_image(api_url, image_data):
    try:
        image_file = io.BytesIO(image_data)
        files = {'file': ('image.jpg', image_file, 'image/jpeg')}
        response = urequests.post(api_url, files=files)

        if response.status_code == 200:
            print(response.json())
        else:
            print(f"Negative response: {response.status_code} - {response.content}")
    except Exception as e:
        print(f"Error uploading image: {e}")

def detection(timer):
    try:
        gc.collect()
        img = capture_image()
        processed_img, detection_results = process_image(img)
        print("Detections: ", detection_results)

        if any(label in desired_labels for label, _ in detection_results):
            image_data = processed_img.compress(quality=90).bytearray()
            upload_image(api_url, image_data)
    except Exception as e:
        print(f"Error in detection process: {e}")

def progress_measurement(timer):
    try:
        img = capture_image()
        processed_img, detection_results = process_image(img)
        image_data = processed_img.compress(quality=90).bytearray()
        upload_image(api_url, image_data)
        print("Progress measurement image uploaded")
    except Exception as e:
        print(f"Error in the progress measurement process: {e}")

def main():

    load_model(model, labels_file)
    connect_wifi(ssid, password)

    try:
        sensor.reset()
        sensor.set_pixformat(sensor.RGB565)
        sensor.set_framesize(sensor.QVGA)
        sensor.skip_frames(time=2000)
    except Exception as e:
        print(f"Error configuring the camera: {e}")

    last_time = time.ticks_ms()
    daily_timer = 0
    daily_event_interval = delta / 3

    while True:
        gc.collect()
        current_time = time.ticks_ms()

        if time.ticks_diff(current_time, last_time) >= frecuency * 1000:
            img = capture_image()
            processed_img, detection_results = process_image(img)
            print("Detections: ", detection_results)

            daily_timer += frecuency

            if (daily_timer >= daily_event_interval):
                image_data = processed_img.compress(quality=90).bytearray()
                upload_image(api_url, image_data)
                daily_timer = 0

            if any(label in desired_labels for label, _ in detection_results):
                image_data = processed_img.compress(quality=90).bytearray()
                upload_image(api_url, image_data)

            last_time = current_time

if __name__ == '__main__':
    main()
