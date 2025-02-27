## Download on [iOS & Android](https://upotq.app.link/trimtalk)

## Features
- **Transcription** – Turn voice messages into text instantly
- **Summarization** – Skip the "uhh" & "ahh"  and get to the key points
- **Translation** – Break language barriers with a single tap
- **Auto-detection** – Get notified when new messages arrive

## Tech Stack
- **Flutter** (Hive, GoRouter, Riverpod, Pigeon for cleaner method channels)
- **Groq** (Whisper)
- **DeepL** for translation
- **Fastlane** for publishing
- **Firebase** (Analytics, Crashlytics, Storage for user feedback)

## How It Works (Expand section below for more details)
- The app checks for new voice message files when opened (manual trigger available).
- Transcriptions are displayed in a list with a summary option.
- Users can enable notification listening for automatic detection.
- If enabled (or if the app is backgrounded), a notification with the transcription is sent.
- On iOS, users must share the audio file manually since files are not programmatically accessible.

<details>
  <summary><span style="font-size: 1.5em; ">Detailed Version</span></summary>

### Finding the Audio Files
WhatsApp stores two types of audio files:
1. **Voice Notes** (standard WhatsApp voice messages)
2. **Audio Files** (shared audio not recorded in WhatsApp)

Trim Talk focuses on **voice notes**, which are stored under:
`/storage/emulated/0/WhatsApp/Media/WhatsApp Voice Notes/`
Each week’s messages are stored in folders formatted as `YEAR-WEEKNUMBER`.
However, WhatsApp does not follow ISO week numbering, requiring a workaround:
- If the expected week's folder is missing, the app checks the previous week instead.

### Reading the Files
Since these files are in another app's dedicated folder, access varies by Android version:
- **Android 12 and below**: Requires `READ_EXTERNAL_STORAGE` permission.
- **Android 13+**: Three options, but only **Storage Access Framework (SAF)** works.
  - Media Store (not possible due to `.nomedia` file preventing indexing).
  - MANAGE_EXTERNAL_STORAGE (restricted to file manager apps).
  - **SAF** (requires user selection of the folder and accessing files via content resolver).

SAF is not well-supported in Flutter. Existing packages failed, so I wrote custom method channel calls to access files.

### Transcribing the Files
Initially, I aimed for on-device transcription, testing multiple solutions:
- **Android Speech-to-Text API** (incompatible with audio files).
- **Whisper (various implementations: TensorFlow, Mediapipe, method channels, etc.)**
  - None provided an optimal balance of performance and accuracy due to mobile hardware limitations.

Cloud-based APIs were tested:
- **Deepgram, Google, AssemblyAI, OpenAI Whisper**
  - Worked but were **slow, inaccurate, or expensive**.
- **Groq**
  - Uses an **LPU™ Inference Engine**, accelerating open-source models like `whisper-large-v3`.
  - **Fast, accurate, and cost-efficient**.

### Automating the Process
To avoid requiring manual checks:
- Used **workmanager** for background tasks (every 15 min), transcribing files and displaying notifications.
- However, **method channels do not work in background tasks** due to separate isolates.
- Tried multiple alternatives without success (likely possible natively, but not in Flutter).
- Best workaround: **Notification Listener Service** to trigger processing (not ideal due to reliability and permissions required).
  </details>
---
## Key Takeaways
- Flutter is powerful but has limitations with native/platform-specific features.
- Android's developer experience is not always fun.
- Groq is an excellent transcription solution.
- Deep understanding of isolates, method channels, and the Flutter engine.
- Experience in building, publishing, and maintaining Flutter packages and apps.
  
## Code & Commands

### Useful Commands
- Generate Hive: `dart run build_runner build -d`
- Generate Pigeon API: `dart run pigeon --input pigeon_api.dart`
- Check the `scripts` folder (fix Pods, publish, etc.)


### Debug Mode
- Notifications always appear.
- WorkManager debug notifications are visible.
- Transcriber returns dummy data.
- read file permission is always true (android)

# Links
Download on [iOS](https://apps.apple.com/ug/app/trimtalk/id6720703110?platform=iphone) and [Android](https://play.google.com/store/apps/details?id=com.trimtalk.app) or share the [Universal Link](https://upotq.app.link/trimtalk).

## Support
I built this project on my free time, if you'd like to support it, consider contributing [here](https://github.com/sponsors/tempo-riz). Thank you! :)