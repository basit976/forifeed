# Import Libraries
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Dropout
from tensorflow.keras.preprocessing.text import Tokenizer
from tensorflow.keras.preprocessing.sequence import pad_sequences
import pandas as pd
from sklearn.model_selection import train_test_split
import re

# Load Dataset
df = pd.read_csv('IMDB Dataset.csv')
df['sentiment'].replace({'positive': 1, 'negative': 0}, inplace=True)

# Preprocess the Data
def preprocess_text(text):
    text = text.lower().strip()
    text = re.sub(r'<.*?>', '', text)  # Remove HTML
    text = re.sub(r'[^a-zA-Z\s]', '', text)  # Remove special characters
    return text

df['review'] = df['review'].apply(preprocess_text)

# Tokenize Text Data
tokenizer = Tokenizer(num_words=5000)
tokenizer.fit_on_texts(df['review'])
sequences = tokenizer.texts_to_sequences(df['review'])
X = pad_sequences(sequences, maxlen=200)  # Padding to ensure equal input size
y = df['sentiment'].values

# Train-Test Split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Build TensorFlow/Keras Model
model = Sequential([
    Dense(64, activation='relu', input_shape=(200,)),
    Dropout(0.5),
    Dense(32, activation='relu'),
    Dense(1, activation='sigmoid')
])

# Compile the Model
model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])

# Train the Model
model.fit(X_train, y_train, epochs=5, batch_size=32, validation_data=(X_test, y_test))

# Save the Model for TensorFlow Lite
model.save('sentiment_model_tf.h5')
