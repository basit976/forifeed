import tensorflow as tf

# Load the TFLite model
try:
    interpreter = tf.lite.Interpreter(model_path="sentiment_model.tflite")
    interpreter.allocate_tensors()
    print("Model loaded and verified successfully!")
except Exception as e:
    print("Error loading model:", e)
