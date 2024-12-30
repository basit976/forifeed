# Convert the Keras Model to TensorFlow Lite
import tensorflow as tf

# Load the Saved Model
keras_model = tf.keras.models.load_model('sentiment_model_tf.h5')

# Convert to TFLite
converter = tf.lite.TFLiteConverter.from_keras_model(keras_model)
tflite_model = converter.convert()

# Save the TFLite Model
with open('sentiment_model.tflite', 'wb') as f:
    f.write(tflite_model)
