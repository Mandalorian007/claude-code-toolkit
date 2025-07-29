# Claude Code Toolkit

Professional Claude Code setup with voice feedback, security protection, and MCP integrations. Get a complete development environment in 30 seconds.

## 🚀 Quick Start

**One-line installation:**
```bash
curl https://raw.githubusercontent.com/yourname/claude-toolkit/main/install.sh | bash
```

**What this does:**
- ✅ Installs hooks, agents, and MCP configurations
- ✅ Sets up `.env` with TODO comments for your API keys
- ✅ Updates `.gitignore` with essential entries
- ✅ Checks system dependencies (advisory only)
- ✅ Creates backup of any existing files

**After installation:**
```bash
# 1. Configure your API keys in .env (see TODO comments)
# 2. Launch Claude Code with environment loaded
export $(cat .env | xargs) && claude
```

## 📋 Prerequisites

The installer will check for these and guide you if missing:
- **[Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview)** - Anthropic's CLI (required)
- **[FFmpeg](https://ffmpeg.org/download.html)** - Required for TTS audio playback
- **[Node.js](https://nodejs.org/)** - Required for MCP servers

## ⚡ Features

- **🎙️ Voice Notifications** - ElevenLabs TTS for agent feedback
- **🛡️ Security Protection** - Blocks dangerous commands (`rm -rf`, etc.)
- **📊 Complete Logging** - All interactions logged to `claude-toolkit-logs/`
- **🤖 Sub-Agents** - Meta-agent creates specialized task agents
- **🔗 MCP Integration** - Perplexity, Firecrawl, YouTube, Reddit, Playwright tools

## 📁 What Gets Installed

```
your-project/
├── .claude/
│   ├── settings.json              # Hook configurations & MCP permissions
│   ├── agents/                    # Sub-agent configurations
│   │   ├── meta-agent.md          # Agent that creates other agents
│   │   └── research-agent.md      # Multi-source research specialist
│   ├── commands/
│   │   ├── prime.md               # Project context loader
│   │   └── all_tools.md           # Tool discovery
│   └── hooks/
│       ├── user_prompt_submit.py  # Logs user prompts
│       ├── pre_tool_use.py        # Security gate for dangerous commands
│       ├── post_tool_use.py       # Tool execution logging
│       ├── notification.py        # Voice notifications with ElevenLabs TTS
│       ├── stop.py                # Completion messages with ElevenLabs TTS
│       └── utils/tts/elevenlabs_tts.py  # ElevenLabs voice synthesis
├── .mcp.json                      # MCP server configurations
├── claude-toolkit-logs/           # Hook execution logs
├── README.md                      # This file
└── .env                          # Your environment variables (not in git)
```

## 🎯 Usage

- **Load project context**: `/prime`
- **List available tools**: `/all_tools`
- **Create new agents**: Ask the meta-agent to create specialized sub-agents
- **Research tasks**: Automatically delegated to research-agent

All hooks provide intelligent logging, security protection, and voice feedback automatically.

## 🔗 MCP Servers

- **Perplexity** - Real-time web search and AI Q&A
- **Firecrawl** - Advanced web scraping and content extraction
- **YouTube** - Video metadata, transcripts, and analysis
- **Reddit** - Community discussions and content access
- **Playwright** - Browser automation and testing

## 🔧 Manual Setup (Alternative)

If you prefer manual installation or want to understand the components:

1. **Clone or download** the toolkit files to your project
2. **Configure API keys** in `.env`:
   ```bash
   ENGINEER_NAME=your-name
   ELEVENLABS_API_KEY=your-elevenlabs-key
   ELEVENLABS_VOICE_ID=aUNOP2y8xEvi4nZebjIw
   PERPLEXITY_API_KEY=your-perplexity-key
   FIRECRAWL_API_KEY=your-firecrawl-key
   YOUTUBE_API_KEY=your-youtube-key
   YOUTUBE_TRANSCRIPT_LANG=en
   ```
3. **Install dependencies**:
   ```bash
   brew install ffmpeg node  # macOS
   # or your system's package manager
   ```
4. **Launch**: `export $(cat .env | xargs) && claude`

## 🛡️ Safety Features

- **Automatic backups** - Existing files saved to timestamped directory
- **Non-destructive** - Only adds missing entries to `.gitignore`
- **No sudo required** - Safe installation without elevated permissions
- **Advisory dependency checks** - Guides you to install missing tools