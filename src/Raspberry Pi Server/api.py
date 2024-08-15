from flask import Flask, request, send_from_directory, jsonify
import os
import time
import subprocess
from flask_cors import CORS
import datetime

app = Flask(__name__)
cors = CORS(app)

UPLOAD_DIRECTORY = 'images'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg'}

os.makedirs(UPLOAD_DIRECTORY, exist_ok=True)

@app.route('/')
def home():
	return "Welcome to orchid images API"

@app.route('/set_date', methods = ['POST'])
def set_date():
	"""Set the date"""
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
	"""Avaiable Images to Download"""
	files = os.listdir(UPLOAD_DIRECTORY)
	return jsonify(files)

@app.route('/images/<filename>', methods = ['GET'])
def get_image(filename):
	"""Download a specific image"""
	return send_from_directory(UPLOAD_DIRECTORY, filename)

def allowed_file(filename):
	return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/upload', methods = ['POST'])
def upload():
	"""Upload New Image"""
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
