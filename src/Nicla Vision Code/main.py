import network
import urequests
import sensor
import image
import time
import io
import os, tf, math, uos, gc
import omv

# Configuration constants
ssid = 'plantsAccesPoint' # Wi-Fi SSID to connect to
password = 'ChangeMe' # Wi-Fi password
api_url = 'http://10.3.141.1:5000/upload' # API endpoint for uploading images
model = 'trained.tflite' # Path to the TensorFlow Lite model
labels_file = 'labels.txt' # Path to the file containing label names
min_confidence = 0.70 # Minimum confidence level for object detection
frecuency = 1 # Frequency in seconds for object detection loop
delta = 86400 # Interval in seconds for progress measurements (1 day)
colors = [(255, 0, 0), (0, 255, 0), (0, 0, 255)] # Colors for drawing detection results
desired_labels = ['State 1', 'State 2', 'State 3', 'Orchidaceae'] # Labels to trigger image upload

def load_model(model, labels_file):
    """
    Load the TensorFlow Lite model and corresponding labels.

    Args:
        model (str): Path to the TensorFlow Lite model file.
        labels_file (str): Path to the labels file.
    """
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
    """
    Connect to a Wi-Fi network.

    Args:
        ssid (str): The Wi-Fi SSID.
        password (str): The Wi-Fi password.

    Prints:
        Connection status and IP address upon success, error message upon failure.
    """
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
    """
    Capture an image using the sensor.

    Returns:
        Image object if successful, 0 if failed.
    """
    try:
        img = sensor.snapshot()
        return img
    except Exception as e:
        print(f"Error capturing the image: {e}")
        return 0

def process_image(img):
    """
    Process an image to perform object detection using the loaded model.

    Args:
        img (Image): The image to process.

    Returns:
        tuple: Processed image with drawn circles and detection results (label, bounding box).
    """
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
    """
    Upload an image to the API endpoint.

    Args:
        api_url (str): The API URL to which the image will be uploaded.
        image_data (bytes): The image data to upload.

    Prints:
        Response from the server or an error message in case of failure.
    """
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
    """
    Periodically perform object detection and upload images if desired labels are detected.

    Args:
        timer: Timer object (unused in this function).
    
    Prints:
        Detection results and uploads the image if relevant objects are detected.
    """
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
    """
    Capture an image periodically to track progress over time and upload it.

    Args:
        timer: Timer object (unused in this function).

    Prints:
        Confirmation message after uploading the progress measurement image.
    """
    try:
        img = capture_image()
        processed_img, detection_results = process_image(img)
        image_data = processed_img.compress(quality=90).bytearray()
        upload_image(api_url, image_data)
        print("Progress measurement image uploaded")
    except Exception as e:
        print(f"Error in the progress measurement process: {e}")

def main():
    # Load model and connect to Wi-Fi
    load_model(model, labels_file)
    connect_wifi(ssid, password)

    # Initialize and configure the sensor (camera)
    try:
        sensor.reset()
        sensor.set_pixformat(sensor.RGB565)
        sensor.set_framesize(sensor.QVGA)
        sensor.skip_frames(time=2000)
    except Exception as e:
        print(f"Error configuring the camera: {e}")

    # Timing variables for periodic tasks
    last_time = time.ticks_ms()
    daily_timer = 0
    daily_event_interval = delta / 3

    while True:
        gc.collect()
        current_time = time.ticks_ms()

         # Check if it's time to perform object detection based on frequency
        if time.ticks_diff(current_time, last_time) >= frecuency * 1000:
            img = capture_image()
            processed_img, detection_results = process_image(img)
            print("Detections: ", detection_results)

            daily_timer += frecuency

            # Perform progress measurement upload after a set interval
            if (daily_timer >= daily_event_interval):
                image_data = processed_img.compress(quality=90).bytearray()
                upload_image(api_url, image_data)
                daily_timer = 0

            # If any desired label is detected, upload the image
            if any(label in desired_labels for label, _ in detection_results):
                image_data = processed_img.compress(quality=90).bytearray()
                upload_image(api_url, image_data)

            last_time = current_time

if __name__ == '__main__':
    main()
