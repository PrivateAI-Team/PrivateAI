# PrivateAI for macOS

A native, simple, and private chat client for Google's Gemini models, running directly on your Mac. Chat with the AI, organize your ideas, analyze documents, and transcribe audio, all within a clean, privacy-focused interface.

---

## Quick Installation

To install PrivateAI, follow these three simple steps:

1.  **Download:** Download the `PrivateAIApp.zip` file from the releases page.
2.  **Unzip:** Double-click the `.zip` file to extract it.
3.  **Move:** Drag the `PrivateAI.app` application icon into your **Applications** folder.

That's it! You can now open PrivateAI from your Applications folder or Launchpad.

## Getting Started: Setting Up Your API Key

To ensure privacy and full control over your interactions, the application works best with your own Google AI Studio API key.

1.  **Open the App:** Launch PrivateAI.
2.  **Access Settings:** In the top menu bar, click `PrivateAI > Settings` (or use the shortcut `Cmd+,`).
3.  **Paste Your Key:** In the "Authentication" section, paste your Google API key into the field.
    * *If you leave the field blank, the application will use a default API key, but using a personal key is highly recommended*. The app will alert you if a valid key is not found.
4.  **Start Chatting:** Close the settings window and click the `+ New Chat` button in the sidebar to send your first message.

## Features

* **Privacy First:** All your chat history is saved locally on your computer in the `Application Support` folder. Your API keys are stored locally, and conversations are sent directly to the Google API.
* **Multiple Chats:** Organize your conversations into separate sessions, which are automatically saved and grouped by date.
* **History Search:** Easily find old conversations using the built-in search bar.
* **File Uploads:**
    * **PDFs:** Upload a PDF document, and the app will extract the text so you can analyze it with the AI.
    * **Audio:** Upload an audio file (e.g., `.mp3`, `.wav`), and PrivateAI will transcribe it to text using Apple's technology.
* **Gemini Models Support:** Choose between the `gemini-1.5-flash-latest` and `gemini-1.5-pro-latest` models directly in the app's settings.
* **Native macOS Interface:** Built with SwiftUI to be fast, lightweight, and integrated with the system, including support for light, dark, and system themes.
* **Simple Management:** Delete individual chats or your entire history with a single click.

## Future Features

We are working to expand PrivateAI's capabilities. In a future update, we plan to introduce the option to run a **fully local AI model**, directly on your Mac, for even greater privacy and control.

This new functionality will exist alongside the current integrations, allowing you to choose between the local AI, Google's Gemini, and other AI services that will be added.

## System Requirements

* **Operating System:** macOS 14+.
