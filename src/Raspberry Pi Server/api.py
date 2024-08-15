from flask import Flask, request, send_from_directory, jsonify
import os
import time
import subprocess
from flask_cors import CORS
import datetime

app = Flask(__name__)

# Enable Cross-Origin Resource Sharing (CORS) for the app to allow cross-origin requests.
cors = CORS(app)

UPLOAD_DIRECTORY = 'images'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg'}

# Ensure that the upload directory exists, if not, it is created.
os.makedirs(UPLOAD_DIRECTORY, exist_ok=True)

@app.route('/')
def home():
	return "Welcome to orchid images API"

@app.route('/set_date', methods = ['POST'])
def set_date():
	"""
	Endpoint to set the system date and time.
	
	Expects a POST request with 'new_date' in the format 'YYYY-MM-DD HH:MM:SS' as form data.
        This endpoint sets the system date and time using the `date` command via `subprocess`.
	
	Returns:
	   JSON response with a success or error message depending on the outcome.
	"""
	new_date = request.form.get('new_date')
	if new_date:
		try:
			datetime.datetime.strptime(new_date, "%Y-%m-%d %H:%M:%S")
		except ValueError:
			return jsonify({'error': 'Invalid date format'}), 400

		try:
			subprocess.run(['sudo', 'date', '--set', new_date], check=True)
			return jsonify({'message': f'{new_date} set'}), 200
		except subprocess.CalledProcessError as e:
			return jsonify({'error': str(e)}), 500
	else:
		return jsonify({'error': 'No date provided'}), 400

@app.route('/images', methods = ['GET'])
def list_images():
    	"""
    	Endpoint to list all available images in the upload directory.
	
    	Returns:
	   A JSON list of filenames of all images stored in the upload directory.
	"""
	files = os.listdir(UPLOAD_DIRECTORY)
	return jsonify(files)

@app.route('/images/<filename>', methods = ['GET'])
def get_image(filename):
    	"""
    	Endpoint to download a specific image by filename.

    	Args:
	   filename (str): The name of the image file to be downloaded.

   	Returns:
	   The requested image file if it exists, otherwise an error response.
    	"""
	return send_from_directory(UPLOAD_DIRECTORY, filename)

def allowed_file(filename):
    	"""
    	Helper function to check if a file has an allowed extension.

    	Args:
	   filename (str): The name of the file to be checked.

    	Returns:
	   bool: True if the file extension is allowed, False otherwise.
    	"""
	return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/upload', methods = ['POST'])
def upload():
	"""
	Endpoint to upload a new image file.
	
	Expects a file as part of the POST request. Only files with allowed extensions (png, jpg, jpeg) are accepted.
	The file is renamed with a timestamp to prevent overwriting and stored in the upload directory.
	
	Returns:
	   JSON response with a success or error message depending on the outcome.
	"""
	if 'file' not in request.files:
		return jsonify({'error': 'File not found'}), 400
	file = request.files['file']
	if file.filename == '':
		return jsonify({'error': 'File name is empty'}), 400
	if allowed_file(file.filename):
		filename = file.filename.split(".")[0] + time.strftime(" %Y-%m-%d at %H.%M.%S.") + file.filename.split(".")[1]
		filepath = os.path.join(UPLOAD_DIRECTORY, filename)
		file.save(filepath)
		return jsonify({'message': f'File {filename} successfully uploaded'}), 200
	return jsonify({'error': 'Invalid file type'}), 400

if __name__ == '__main__':
	app.run(host='0.0.0.0', port = 5000)
