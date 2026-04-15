import torch
import torchvision.transforms as transforms
from PIL import Image
import io
import os

# Get the absolute path to the model file
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MODEL_PATH = os.path.join(BASE_DIR, "ml_models", "efficientnet_b0_id_verification.pth")

_model = None

def get_model():
    global _model
    if _model is None:
        print(f"Attempting to load model from: {MODEL_PATH}")
        if os.path.exists(MODEL_PATH):
            try:
                # Set weights_only=False because the .pth contains the full model object
                # and we trust the source (your own training notebook)
                _model = torch.load(MODEL_PATH, map_location=torch.device('cpu'), weights_only=False)
                _model.eval()
                print(f"Model loaded successfully.")
            except Exception as e:
                print(f"CRITICAL: Error loading model: {e}")
                _model = None
        else:
            print(f"CRITICAL: Model file NOT FOUND at {MODEL_PATH}")
    return _model

def verify_id_image(image_bytes: bytes) -> bool:
    """
    Verifies if an image of an ID is legitimate using the fine-tuned EfficientNet-B0 model.
    """
    model = get_model()
    if model is None:
        print("Verification failed: Model not loaded.")
        return False

    try:
        image = Image.open(io.BytesIO(image_bytes)).convert('RGB')
        
        # Preprocessing matching the 'val' transforms in the training notebook
        preprocess = transforms.Compose([
            transforms.Resize((224, 224)),
            transforms.ToTensor(),
            transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
        ])
        
        input_tensor = preprocess(image).unsqueeze(0)
        
        with torch.no_grad():
            output = model(input_tensor)
            # Log the raw logits to see what the model is actually thinking
            print(f"Model Raw Output (Logits): {output}")
            
            # Add softmax to print out probabilities
            probabilities = torch.nn.functional.softmax(output, dim=1)
            print(f"Model Probabilities: {probabilities}")
            
            _, predicted = torch.max(output, 1)
            predicted_idx = predicted.item()
            
            # Based on the notebook: classes = ['AI_Fake', 'AI_Real']
            # Index 0 is Fake, Index 1 is Real
            is_legitimate = (predicted_idx == 1)
            
            print(f"Predicted Index: {predicted_idx} ({'Real' if is_legitimate else 'Fake'})")
            return is_legitimate
            
    except Exception as e:
        print(f"Error during ID verification execution: {e}")
        return False
