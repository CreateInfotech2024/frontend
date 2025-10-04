# WebRTC Setup Guide for Beauty LMS Flutter App

This guide explains the WebRTC implementation in the Flutter app for real-time video and audio streaming.

## 🎥 Features Implemented

### ✅ Core WebRTC Functionality
- **Local Media Access**: Camera and microphone initialization
- **Peer-to-Peer Connections**: Direct video/audio streaming between participants
- **WebRTC Signaling**: Socket.IO-based offer/answer/ICE candidate exchange
- **Multi-participant Support**: Grid layout for multiple video streams
- **Media Controls**: Toggle audio/video on/off in real-time

### ✅ User Experience
- **Local Video Preview**: Small overlay showing your camera feed
- **Remote Video Grid**: Adaptive grid layout for participant videos
- **Loading States**: Visual feedback during media initialization
- **Participant Labels**: Display names and host indicators on video feeds
- **Responsive Layout**: Adapts to different screen sizes

## 🏗️ Architecture

### WebRTC Service (`webrtc_service.dart`)
The WebRTC service manages all peer connections and media streams:

```dart
WebRTCService
├── initializeLocalMedia()     # Access camera/microphone
├── setupSignaling()            # Listen for WebRTC signals
├── createOffer()               # Initiate connection to peer
├── toggleAudio()               # Mute/unmute microphone
├── toggleVideo()               # Turn camera on/off
└── cleanup()                   # Release resources
```

### Socket Service Updates (`socket_service.dart`)
Added WebRTC signaling events:

```dart
// Sending
- sendOffer(offer, to)
- sendAnswer(answer, to)
- sendIceCandidate(candidate, to)
- toggleAudio(enabled)
- toggleVideo(enabled)

// Receiving
- onOffer(callback)
- onAnswer(callback)
- onIceCandidate(callback)
- onParticipantAudioToggle(callback)
- onParticipantVideoToggle(callback)
```

### Meeting Room Screen Updates
The meeting room screen now includes:

1. **Video Renderers**: 
   - Local renderer for your camera
   - Map of remote renderers for other participants

2. **Media Initialization**:
   - Async initialization of camera/microphone
   - Error handling for permission denials
   - Loading states during initialization

3. **Peer Connection Management**:
   - Automatic offer creation when participants join
   - Cleanup when participants leave
   - Proper disposal of resources

4. **UI Components**:
   - Local video overlay (top-right corner)
   - Remote videos in adaptive grid
   - Working mute/camera toggle buttons

## 📱 Platform-Specific Setup

### Web (Chrome/Edge/Safari)
**Permissions**: Browser will prompt for camera/microphone access
**HTTPS Required**: WebRTC only works over HTTPS (or localhost)
**Supported Browsers**: Chrome, Edge, Safari, Firefox

### Android
**Permissions** (add to `AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />

<uses-feature android:name="android.hardware.camera" />
<uses-feature android:name="android.hardware.camera.autofocus" />
```

### iOS
**Permissions** (add to `Info.plist`):
```xml
<key>NSCameraUsageDescription</key>
<string>Beauty LMS needs camera access for video calls</string>
<key>NSMicrophoneUsageDescription</key>
<string>Beauty LMS needs microphone access for audio calls</string>
```

## 🔧 Configuration

### STUN Servers
The app uses Google's public STUN servers:
```dart
{
  'iceServers': [
    {'urls': 'stun:stun.l.google.com:19302'},
    {'urls': 'stun:stun1.l.google.com:19302'},
  ]
}
```

### Media Constraints
Default video/audio settings:
```dart
{
  'audio': true,
  'video': {
    'facingMode': 'user',
    'width': {'ideal': 640},
    'height': {'ideal': 480},
  }
}
```

## 🚀 Usage Flow

### For Host (Course Creator)
1. Create course → App initializes camera/microphone
2. Wait for participants to join
3. When participant joins → WebRTC offer is sent automatically
4. Once connected → Host video is visible to participant

### For Participant (Course Joiner)
1. Join course → App initializes camera/microphone
2. Receive WebRTC offer from host
3. Send back WebRTC answer
4. Once connected → Both videos are visible to each other

### Media Controls
- **Mute/Unmute**: Click microphone button
- **Camera On/Off**: Click camera button
- **Leave Meeting**: Properly cleans up all connections

## 🐛 Troubleshooting

### Camera/Microphone Not Working
1. **Check Permissions**: Ensure browser/app has camera/microphone permissions
2. **HTTPS Required**: WebRTC requires secure context (HTTPS or localhost)
3. **Device Availability**: Ensure camera/microphone is not in use by other apps
4. **Browser Support**: Use modern browsers (Chrome, Edge, Safari, Firefox)

### Video Not Showing
1. **Check Console**: Look for WebRTC errors in debug console
2. **Network Issues**: Ensure both peers can communicate via Socket.IO
3. **Firewall**: Some networks block WebRTC traffic
4. **ICE Candidates**: Ensure STUN servers are reachable

### Connection Issues
1. **Socket.IO Connection**: Verify Socket.IO is connected
2. **Signaling**: Check that offer/answer/ICE candidates are being exchanged
3. **STUN Servers**: Try alternative STUN servers if Google's are blocked
4. **NAT Traversal**: Some networks require TURN servers for connectivity

## 🔒 Security Considerations

1. **Permissions**: Always request user permission before accessing camera/microphone
2. **HTTPS**: WebRTC requires HTTPS in production
3. **Privacy**: Video streams are peer-to-peer (not stored on server)
4. **Disposal**: Always clean up streams and connections when done

## 📊 Performance Tips

1. **Video Quality**: Adjust resolution based on network conditions
2. **Bandwidth**: Lower resolution for slow connections
3. **CPU Usage**: Limit number of simultaneous video streams
4. **Memory**: Properly dispose of renderers and streams

## 🎯 Testing

### Local Testing
```bash
# Run on web (localhost is allowed for WebRTC)
flutter run -d chrome

# Run on Android emulator
flutter run -d emulator-5554

# Run on iOS simulator
flutter run -d ios
```

### Testing Scenarios
1. **Single Participant**: Test camera/microphone initialization
2. **Two Participants**: Test peer-to-peer connection
3. **Multiple Participants**: Test grid layout and performance
4. **Media Toggles**: Test mute/unmute and camera on/off
5. **Leave/Rejoin**: Test cleanup and reconnection

## 📚 Additional Resources

- [Flutter WebRTC Package](https://pub.dev/packages/flutter_webrtc)
- [WebRTC Documentation](https://webrtc.org/)
- [MDN WebRTC Guide](https://developer.mozilla.org/en-US/docs/Web/API/WebRTC_API)
- [Flutter Camera Plugin](https://pub.dev/packages/camera)

## 🔄 Future Enhancements

- [ ] Screen sharing support
- [ ] Video quality settings
- [ ] Network quality indicators
- [ ] Recording functionality
- [ ] Background blur/virtual backgrounds
- [ ] Picture-in-picture mode
- [ ] Adaptive bitrate
