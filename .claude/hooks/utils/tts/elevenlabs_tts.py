#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.8"
# dependencies = [
#   "elevenlabs",
#   "python-dotenv",
# ]
# ///

import os
import sys
from pathlib import Path

try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass  # dotenv is optional

def speak_text(text):
    """
    Speak text using ElevenLabs TTS.
    
    Args:
        text (str): Text to speak
        
    Returns:
        bool: True if successful, False otherwise
    """
    try:
        from elevenlabs import ElevenLabs, play
        
        api_key = os.getenv('ELEVENLABS_API_KEY')
        if not api_key:
            return False
        
        voice_id = os.getenv('ELEVENLABS_VOICE_ID', 'Rachel')
        
        # Initialize ElevenLabs client with API key
        client = ElevenLabs(api_key=api_key)
        
        # Generate audio using the text_to_speech method
        audio = client.text_to_speech.convert(
            voice_id=voice_id,
            text=text,
            model_id="eleven_multilingual_v2"
        )
        
        # Play the audio
        play(audio)
        
        return True
        
    except ImportError:
        return False
    except Exception:
        return False

def main():
    """
    Command line interface for ElevenLabs TTS.
    Usage: python elevenlabs_tts.py "Text to speak"
    """
    if len(sys.argv) < 2:
        print("Usage: elevenlabs_tts.py 'text to speak'", file=sys.stderr)
        sys.exit(1)
    
    # Join all arguments as the text to speak
    text_to_speak = " ".join(sys.argv[1:])
    
    if not text_to_speak.strip():
        sys.exit(0)  # Empty text, exit silently
    
    # Check for API key
    api_key = os.getenv('ELEVENLABS_API_KEY')
    if not api_key:
        sys.exit(1)
    
    # Attempt to speak the text
    success = speak_text(text_to_speak)
    
    if success:
        sys.exit(0)  # Success
    else:
        # Fail silently - don't break the hook flow
        sys.exit(0)

if __name__ == "__main__":
    main() 