#!/bin/bash

# 1. System Dependencies & Environment
apt-get update
apt-get install -y git wget python3-venv libgl1 libglib2.0-0

# Set up workspace
cd /workspace

# 2. Install Wan2GP (Supports Wan 2.1 & 2.2)
if [ ! -d "Wan2GP" ]; then
    git clone https://github.com/deepbeepmeep/Wan2GP.git
fi
cd Wan2GP

# Create and activate virtual environment (Requires Python 3.10+)
python3 -m venv venv
source venv/bin/activate

# Install Python requirements
pip install --upgrade pip
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124
pip install -r requirements.txt
# Optional: Install SageAttention for speed (uncomment if needed)
# pip install sageattention

# 3. Download Your Custom Model (Wan2.1 I2V 14B 480P Q4KM)
# Create checkpoints directory
mkdir -p ckpts

# Download the model from Civitai (Model ID: 2503787)
# Note: "Q4KM" suggests a GGUF/Quantized model. Wan2GP has experimental support for some quantized formats.
echo "Downloading custom model from Civitai..."
wget -O ckpts/Wan2.1_I2V_14B_480P_Q4KM.gguf "https://civitai.com/api/download/models/2503787"

# 4. Register the Custom Model (Create a Profile)
# This creates a JSON file in 'finetunes' so Wan2GP detects the custom model file.
mkdir -p finetunes
cat <<EOF > finetunes/custom_wan_i2v.json
{
    "name": "My Custom Wan2.1 I2V (480P)",
    "description": "Custom Q4KM model from Civitai",
    "architecture": "i2v_2_1",
    "model": {
        "name": "Wan2.1 I2V 14B Q4KM",
        "architecture": "i2v_2_1",
        "URLs": ["/workspace/Wan2GP/ckpts/Wan2.1_I2V_14B_480P_Q4KM.gguf"],
        "auto_quantize": false
    }
}
EOF

# 5. Create a Start Script for Easy Launch
# This script sets the defaults: I2V mode, 14B model, 81 frames (approx 5s)
cat <<EOF > /workspace/start_wan2gp.sh
#!/bin/bash
cd /workspace/Wan2GP
source venv/bin/activate
# Launch with defaults: Image-to-Video, 14B, 81 frames (5 seconds)
# Note: You can select your "My Custom Wan2.1" model from the dropdown in the UI.
python wgp.py --i2v --frames 81 --listen --server-port 17860
EOF

chmod +x /workspace/start_wan2gp.sh

echo "Provisioning complete. Run '/workspace/start_wan2gp.sh' to start."
