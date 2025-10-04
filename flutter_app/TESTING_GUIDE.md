# Testing Guide for WebRTC Implementation

## Quick Test Steps

### Prerequisites
- Flutter SDK installed (3.0.0+)
- Backend server running at `https://krishnabarasiya.space`
- Two devices/browsers for testing (or use two tabs)

### Test 1: Host Creates and Joins Meeting

1. **Run the Flutter app**:
   ```bash
   cd flutter_app
   flutter pub get
   flutter run -d chrome  # or android/ios
   ```

2. **Create a course**:
   - Fill in course details (Name, Description, Instructor Name, etc.)
   - Click "🎥 Create & Start Course"
   - You should see:
     - Camera permission prompt → Allow
     - Loading indicator while initializing
     - Your video feed in small overlay (top-right)
     - "Waiting for participants to join..." in main area

3. **Note the meeting code** (displayed in the AppBar)

### Test 2: Participant Joins Meeting

1. **Open second instance** (new tab or device):
   ```bash
   flutter run -d chrome  # or use different device
   ```

2. **Join the course**:
   - Enter the meeting code from Test 1
   - Enter participant name (e.g., "Test User")
   - Click "🚀 Join Meeting"
   - You should see:
     - Camera permission prompt → Allow
     - Loading indicator while initializing
     - Your video feed in small overlay (top-right)
     - Host's video feed in main area

3. **Verify on Host's screen**:
   - Host should now see participant's video in main area
   - Participant name should be displayed on video feed

### Test 3: Media Controls

**On either device**:

1. **Test Audio Toggle**:
   - Click microphone button
   - Icon should change to `mic_off` (red)
   - Click again to unmute
   - Icon should change back to `mic` (white)

2. **Test Video Toggle**:
   - Click camera button
   - Icon should change to `videocam_off` (red)
   - Your video should turn black on remote participant's screen
   - Click again to turn camera on
   - Icon should change back to `videocam` (white)
   - Your video should reappear on remote participant's screen

### Test 4: Multiple Participants

1. **Open third instance** (another tab/device)
2. **Join with meeting code**
3. **Verify**:
   - All three videos should be visible
   - Grid layout should adapt (2 columns for 2+ participants)
   - Each video should have correct participant name

### Test 5: Leave/End Meeting

**As Participant**:
1. Click "Leave" button
2. Confirm in dialog
3. Should navigate back to home screen
4. Host should see participant removed from list

**As Host**:
1. Click "End Meeting" button
2. Confirm in dialog
3. All participants should be disconnected
4. All should navigate back to home screen

## Expected Behaviors

### ✅ Success Indicators
- Camera/microphone permissions granted
- Local video visible in overlay
- Remote videos visible in grid
- Audio/video toggles work
- Participant list updates in real-time
- Chat messages work
- Clean disconnect on leave/end

### ❌ Common Issues

**Issue**: Camera not showing
- **Check**: Browser permissions granted?
- **Check**: Camera not in use by another app?
- **Check**: Using HTTPS or localhost?

**Issue**: Remote video not showing
- **Check**: Socket.IO connected? (check console logs)
- **Check**: WebRTC signaling working? (check console for offer/answer logs)
- **Check**: Network/firewall blocking WebRTC?

**Issue**: "Failed to initialize media" error
- **Check**: Camera/microphone available?
- **Check**: Browser supports WebRTC?
- **Check**: Permissions not denied?

## Console Logs to Monitor

During testing, watch for these console logs:

```
✅ Connected to Socket.IO server
✅ Local media initialized
📺 Received remote stream from [participantId]
🔗 Connection state with [participantId]: connected
```

## Performance Checks

### Video Quality
- Resolution should be ~640x480 (as configured)
- Smooth playback without major stuttering
- Low latency (< 1 second delay)

### Audio Quality
- Clear audio without echo
- No significant delay
- No distortion

### Resource Usage
- CPU usage reasonable (< 50% on modern devices)
- Memory usage stable (no leaks)
- Network bandwidth acceptable (< 2 Mbps per stream)

## Debugging Tips

### Enable Verbose Logging
Check Flutter console for:
- Socket.IO connection logs
- WebRTC offer/answer/ICE logs
- Media initialization logs
- Error messages

### Browser DevTools (for Web)
1. Open DevTools (F12)
2. Check Console tab for logs
3. Check Network tab for WebSocket connection
4. Check Application → Permissions for camera/mic

### Common Solutions

**Problem**: No video/audio
```bash
# Restart the app
flutter run -d chrome

# Clear browser cache and permissions
# Try incognito/private mode
```

**Problem**: Connection fails
- Check backend is running: `curl https://krishnabarasiya.space/health`
- Check Socket.IO connection: Look for "Connected to Socket.IO" log
- Try different STUN servers if Google's are blocked

**Problem**: Permission denied
- Revoke and re-grant permissions in browser settings
- Try different browser
- Check if camera/mic is available in system settings

## Test Matrix

| Test Case | Expected Result | Status |
|-----------|----------------|--------|
| Host creates meeting | Camera initializes, shows local video | ⏳ |
| Participant joins | Both videos visible | ⏳ |
| Audio toggle | Mutes/unmutes correctly | ⏳ |
| Video toggle | Camera on/off works | ⏳ |
| Multiple participants | Grid layout works | ⏳ |
| Participant leaves | Video removed, connection closed | ⏳ |
| Host ends meeting | All disconnected | ⏳ |
| Chat functionality | Messages work alongside video | ⏳ |
| Network reconnect | Handles connection loss gracefully | ⏳ |

## Next Steps After Testing

1. ✅ Mark test cases as passed/failed
2. 📝 Document any issues found
3. 🐛 Create bug reports for failures
4. 🎯 Test on different platforms (Android, iOS, Web)
5. 📊 Measure performance metrics
6. 🔧 Optimize based on findings

## Support

If you encounter issues:
1. Check console logs for errors
2. Review WEBRTC_SETUP.md for configuration
3. Verify backend is running and accessible
4. Test with simple WebRTC test tools first
5. Check browser/device compatibility

## Notes

- WebRTC requires HTTPS in production (localhost is OK for testing)
- Some networks/firewalls may block WebRTC traffic
- Mobile data networks may have restrictions
- Consider using TURN servers for better connectivity in restrictive networks
