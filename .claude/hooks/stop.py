#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "python-dotenv",
# ]
# ///
import argparse
import json
import os
import sys
import random
import subprocess
from pathlib import Path
from datetime import datetime

# Load environment variables if available
try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass  # dotenv is optional

def get_completion_messages():
    """Return list of friendly completion messages."""
    return [
        "Work complete!",
        "All done!",
        "Task finished!",
        "Job complete!",
        "Ready for next task!"
    ]

def announce_completion():
    """Announce completion using ElevenLabs TTS."""
    try:
        # Get the ElevenLabs TTS script path
        script_dir = Path(__file__).parent
        elevenlabs_script = script_dir / "utils" / "tts" / "elevenlabs_tts.py"
        
        if not elevenlabs_script.exists():
            return  # No TTS script available
        
        # Check for API key
        if not os.getenv('ELEVENLABS_API_KEY'):
            return  # No API key configured
        
        # Get a random completion message
        completion_message = random.choice(get_completion_messages())
        
        # Call the ElevenLabs TTS script
        subprocess.run([
            "uv", "run", str(elevenlabs_script), completion_message
        ],
        capture_output=True,  # Suppress output
        timeout=10  # 10-second timeout
        )
        
    except (subprocess.TimeoutExpired, subprocess.SubprocessError, FileNotFoundError):
        # Fail silently if TTS encounters issues
        pass
    except Exception:
        # Fail silently for any other errors
        pass

def main():
    try:
        # Parse command line arguments
        parser = argparse.ArgumentParser()
        parser.add_argument('--chat', action='store_true', help='Enable completion notifications')
        args = parser.parse_args()
        
        # Read JSON input from stdin
        input_data = json.loads(sys.stdin.read())
        
        # Announce completion via TTS if --chat flag is provided
        if args.chat:
            announce_completion()
        
        sys.exit(0)
        
    except json.JSONDecodeError:
        # Handle JSON decode errors gracefully
        sys.exit(0)
    except Exception:
        # Handle any other errors gracefully
        sys.exit(0)

if __name__ == "__main__":
    main() 