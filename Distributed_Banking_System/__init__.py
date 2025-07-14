from flask import Flask
from routes import create_routes
import logging
from flask_cors import CORS


def create_app():
    app = Flask(__name__, template_folder='./templates')
    CORS(app)
    # Hardcoded configurations (PostgreSQL)

    app.config['SECRET_KEY'] = 'your-secret-key'

    create_routes(app)  # Ensure the routes are created

    return app


if __name__ == '__main__':
    # Set up logging
    logging.basicConfig(level=logging.INFO)

    # Start the Flask app
    app = create_app()
    app.run(debug=True)
