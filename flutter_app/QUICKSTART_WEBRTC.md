# WebRTC Quick Start Guide

Get video/audio working in 5 minutes!

## 🚀 Quick Setup

### 1. Install Dependencies

```bash
cd flutter_app
flutter pub get
```

This installs the new `flutter_webrtc` package (v0.9.48).

### 2. Run the App

```bash
# Web (easiest for testing)
flutter run -d chrome

# Android
flutter run -d android

# iOS (macOS only)
flutter run -d ios
```

### 3. Test with Two Devices/Tabs

**Tab 1 (Host)**:
1. Fill in course details
2. Click "🎥 Create & Start Course"
3. Allow camera/microphone access
4. Note the meeting code (e.g., "ABC123")

**Tab 2 (Participant)**:
1. Enter the meeting code from Tab 1
2. Enter your name
3. Click "🚀 Join Meeting"
4. Allow camera/microphone access
5. You should now see both videos!

## ✅ What's Working

### Video Features
- ✅ Local camera preview (small overlay, top-right)
- ✅ Remote participant videos (main grid area)
- ✅ Multi-participant support (grid adapts)
- ✅ Participant names on videos
- ✅ Host indicator (⭐ icon)

### Audio Features
- ✅ Microphone access
- ✅ Two-way audio streaming
- ✅ Mute/unmute toggle

### Controls
- ✅ **Mute Button**: Click to mute/unmute microphone
  - White = unmuted, Red = muted
- ✅ **Camera Button**: Click to turn camera on/off
  - White = on, Red = off
- ✅ **Leave/End Button**: Exit meeting properly

### Real-time Updates
- ✅ Participant join notifications
- ✅ Participant leave notifications
- ✅ Chat messages
- ✅ Participant list updates

## 🎥 How It Works (Simple Version)

```
1. Host Creates Meeting
   └─► Camera/Mic initialized
   └─► Waits for participants
   
2. Participant Joins
   └─► Camera/Mic initialized
   └─► Sends "join" signal
   
3. WebRTC Connection
   Host: "Here's my video!" (Offer)
   Participant: "Got it, here's mine!" (Answer)
   └─► Connection established
   └─► Both see each other's video
```

## 📁 Files Modified

### New Files Created
- `lib/services/webrtc_service.dart` - WebRTC logic
- `WEBRTC_SETUP.md` - Detailed setup
- `TESTING_GUIDE.md` - Testing instructions
- `IMPLEMENTATION_SUMMARY.md` - Technical details
- `ARCHITECTURE_DIAGRAM.md` - Visual diagrams

### Files Updated
- `pubspec.yaml` - Added flutter_webrtc package
- `lib/services/socket_service.dart` - WebRTC signaling
- `lib/screens/meeting_room_screen.dart` - Video UI

## 🐛 Troubleshooting

### Camera Not Showing?
1. Check browser permissions (look for 🎥 icon in address bar)
2. Make sure camera is not in use by another app
3. Try refreshing the page
4. Check console for errors (F12 → Console)

### No Remote Video?
1. Check both devices granted camera/mic permissions
2. Look for "Connected to Socket.IO" in console
3. Check network/firewall settings
4. Try different browser (Chrome works best)

### Audio Not Working?
1. Check microphone permissions
2. Check system audio settings
3. Try mute/unmute toggle
4. Check if microphone is selected in browser settings

### "Failed to initialize media" Error?
- **Solution**: Camera/microphone permissions denied
- **Fix**: Allow permissions in browser settings and reload

### Connection Timeout?
- **Solution**: Backend server not reachable
- **Fix**: Check backend URL in `socket_service.dart`
- **Verify**: Visit https://krishnabarasiya.space/health

## 📱 Platform-Specific Notes

### Web (Chrome/Edge/Safari)
- ✅ Works on localhost (no HTTPS needed)
- ✅ Requires HTTPS in production
- ✅ Browser prompts for permissions automatically

### Android
**Add to `android/app/src/main/AndroidManifest.xml`**:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS
**Add to `ios/Runner/Info.plist`**:
```xml
<key>NSCameraUsageDescription</key>
<string>Beauty LMS needs camera access for video calls</string>
<key>NSMicrophoneUsageDescription</key>
<string>Beauty LMS needs microphone access for audio calls</string>
```

## 🎯 Quick Test Checklist

- [ ] Host creates meeting successfully
- [ ] Host sees own video in top-right corner
- [ ] Participant can join with meeting code
- [ ] Participant sees own video in top-right
- [ ] Both see each other's video in main area
- [ ] Mute button works (turns red when muted)
- [ ] Camera button works (turns red when off)
- [ ] Chat messages work alongside video
- [ ] Leave/end meeting disconnects properly

## 💡 Tips for Best Experience

### For Development
- Use Chrome for best WebRTC support
- Open DevTools console to see debug logs
- Test on localhost first (HTTPS not required)
- Use two different browsers/devices for realistic test

### For Production
- Ensure HTTPS is enabled
- Configure TURN servers for restrictive networks
- Test on target devices (mobile, desktop)
- Monitor network bandwidth usage

### Performance
- Limit to 4-6 participants for best quality
- Lower resolution on slow connections
- Close other camera-using apps
- Use wired internet when possible

## 📊 Expected Console Output

When everything works, you should see:

```
✅ Connected to Socket.IO server
✅ Local media initialized
📺 Received remote stream from [participant-id]
🔗 Connection state with [participant-id]: connected
```

## 🔧 Configuration

### Video Quality (in `webrtc_service.dart`)
```dart
final Map<String, dynamic> _mediaConstraints = {
  'audio': true,
  'video': {
    'facingMode': 'user',
    'width': {'ideal': 640},   // Change this
    'height': {'ideal': 480},  // Change this
  }
};
```

### STUN Servers (in `webrtc_service.dart`)
```dart
final Map<String, dynamic> _configuration = {
  'iceServers': [
    {'urls': 'stun:stun.l.google.com:19302'},
    {'urls': 'stun:stun1.l.google.com:19302'},
    // Add more STUN/TURN servers here
  ]
};
```

## 📚 More Resources

- **Detailed Setup**: See `WEBRTC_SETUP.md`
- **Testing Guide**: See `TESTING_GUIDE.md`
- **Architecture**: See `ARCHITECTURE_DIAGRAM.md`
- **Implementation**: See `IMPLEMENTATION_SUMMARY.md`

## 🆘 Still Having Issues?

1. **Check Console Logs**: Look for error messages (F12 → Console)
2. **Verify Backend**: Check if `https://krishnabarasiya.space` is accessible
3. **Test Permissions**: Ensure camera/microphone permissions granted
4. **Try Simple Test**: Use https://webrtc.github.io/samples/ to verify browser support
5. **Update Flutter**: Make sure you're using Flutter 3.0.0+

## ✨ What's Next?

After getting basic video working, you can:
1. Test with multiple participants (3-4 people)
2. Try different network conditions
3. Test on mobile devices
4. Measure performance and bandwidth
5. Explore advanced features (screen sharing, recording)

## 🎉 Success!

If you see your video and the other person's video, congratulations! You've successfully implemented WebRTC video conferencing in Flutter!

---

**Need Help?** Check the detailed guides in the `flutter_app/` directory or open an issue on GitHub.
