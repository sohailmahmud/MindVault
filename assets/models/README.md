# MindVault Text Embedding Model

This directory contains the TensorFlow Lite models used for AI-powered semantic search.

## Files:
- `text_embedding_model.tflite` - The main text embedding model (to be added)
- `vocab.txt` - Vocabulary file for tokenization
- `README.md` - This file

## Model Requirements:
- Input: Text sequences (max 128 tokens)
- Output: 384-dimensional embeddings
- Format: TensorFlow Lite (.tflite)

## How to Add Your Model:
1. Train or download a text embedding model
2. Convert to TensorFlow Lite format
3. Place the .tflite file in this directory
4. Update the vocabulary file if needed
5. Update the constants in TfLiteService if dimensions differ

## Recommended Models:
- Universal Sentence Encoder Lite
- MobileBERT
- DistilBERT (converted to TFLite)
- Custom trained embedding models

Note: Currently using fallback hash-based embeddings until a real model is added.