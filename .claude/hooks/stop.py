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
        parser.add_argument('--chat', action='store_true', help='Convert transcript to chat format')
        args = parser.parse_args()
        
        # Read JSON input from stdin
        input_data = json.loads(sys.stdin.read())
        
        # Ensure log directory exists
        log_dir = os.path.join(os.getcwd(), 'claude-toolkit-logs')
        os.makedirs(log_dir, exist_ok=True)
        log_file = os.path.join(log_dir, 'stop.json')
        
        # Read existing log data or initialize empty list
        if os.path.exists(log_file):
            with open(log_file, 'r') as f:
                try:
                    log_data = json.load(f)
                except (json.JSONDecodeError, ValueError):
                    log_data = []
        else:
            log_data = []
        
        # Add timestamp to input data
        input_data['timestamp'] = datetime.now().isoformat()
        
        # Append new data
        log_data.append(input_data)
        
        # Write back to file with formatting
        with open(log_file, 'w') as f:
            json.dump(log_data, f, indent=2)
        
        # Convert transcript to chat format if --chat flag is provided
        if args.chat:
            try:
                transcript_path = os.path.join(os.getcwd(), 'transcript.jsonl')
                if os.path.exists(transcript_path):
                    chat_data = []
                    with open(transcript_path, 'r') as f:
                        for line in f:
                            line = line.strip()
                            if line:
                                try:
                                    chat_data.append(json.loads(line))
                                except json.JSONDecodeError:
                                    pass  # Skip invalid lines
                    
                    # Write to claude-toolkit-logs/chat.json
                    chat_file = os.path.join(log_dir, 'chat.json')
                    with open(chat_file, 'w') as f:
                        json.dump(chat_data, f, indent=2)
            except Exception:
                pass  # Fail silently
        
        # Announce completion via TTS
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