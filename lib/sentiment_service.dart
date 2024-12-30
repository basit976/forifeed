import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:typed_data';

class SentimentService {
  Interpreter? interpreter;

  // Load the model
  Future<void> loadModel() async {
    interpreter = await Interpreter.fromAsset('sentiment_model.tflite');
    print('Sentiment model loaded.');
  }

  // Analyze sentiment
  Future<String> analyzeSentiment(String text) async {
    if (interpreter == null) {
      throw Exception('Model not loaded. Call loadModel() before analyzeSentiment().');
    }

    // Preprocess text (tokenize and pad)
    List<double> input = preprocessText(text, 256); // Adjust maxLength

    // Convert to Float32List
    var inputTensor = Float32List.fromList(input);

    // Allocate output buffer
    var output = List.filled(3, 0.0).reshape([1, 3]); // Adjust to model output shape

    // Run inference
    interpreter!.run(inputTensor, output);

    // Get the result
    int sentimentIndex = output[0].indexOf(output[0].reduce((a, b) => a > b ? a : b));
    String sentiment = ['negative', 'neutral', 'positive'][sentimentIndex];

    return sentiment;
  }

  // Preprocess text into a list of double values
  List<double> preprocessText(String text, int maxLength) {
    List<double> tokens = text.split(' ').map((word) => word.hashCode.toDouble()).toList();
    tokens = tokens.take(maxLength).toList(); // Truncate
    while (tokens.length < maxLength) {
      tokens.add(0.0); // Pad with zeros
    }
    return tokens;
  }

  // Close the model to release resources
  void closeModel() {
    if (interpreter != null) {
      interpreter!.close();
      interpreter = null;
      print('Sentiment model resources released.');
    }
  }

  // Dispose method to ensure proper cleanup
  void dispose() {
    closeModel();
  }
}
