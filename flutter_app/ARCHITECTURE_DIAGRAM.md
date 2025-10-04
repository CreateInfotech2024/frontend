# WebRTC Architecture Diagram

## High-Level Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                         Flutter App                               │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │            Meeting Room Screen (UI Layer)               │    │
│  │  ┌──────────────────────────────────────────────────┐   │    │
│  │  │  Local Video     │    Remote Videos Grid         │   │    │
│  │  │  (Overlay)       │    (Main Area)                │   │    │
│  │  │  - RTCVideoView  │    - GridView.builder          │   │    │
│  │  │  - _localRenderer│    - _remoteRenderers Map     │   │    │
│  │  └──────────────────────────────────────────────────┘   │    │
│  │  ┌──────────────────────────────────────────────────┐   │    │
│  │  │  Controls Bar                                     │   │    │
│  │  │  [Mute] [Camera] [Share] [Leave/End]            │   │    │
│  │  └──────────────────────────────────────────────────┘   │    │
│  └───────────────────┬──────────────────────────────────────┘    │
│                      │                                            │
│  ┌───────────────────┴──────────────────┬───────────────────┐    │
│  │                                      │                   │    │
│  ▼                                      ▼                   ▼    │
│ ┌─────────────────┐    ┌─────────────────┐   ┌──────────────┐  │
│ │ WebRTCService   │    │ SocketService   │   │ APIService   │  │
│ │                 │◄───┤                 │   │              │  │
│ │ - PeerConns     │    │ - Signaling     │   │ - REST API   │  │
│ │ - MediaStreams  │    │ - Real-time     │   │ - HTTP calls │  │
│ │ - Audio/Video   │    │ - Events        │   │              │  │
│ └────────┬────────┘    └────────┬────────┘   └──────────────┘  │
│          │                      │                                │
└──────────┼──────────────────────┼────────────────────────────────┘
           │                      │
           ▼                      ▼
    ┌──────────────┐      ┌──────────────┐
    │ flutter_     │      │ socket_io_   │
    │ webrtc       │      │ client       │
    │ (Native RTC) │      │ (WebSocket)  │
    └──────────────┘      └──────────────┘
           │                      │
           └──────────┬───────────┘
                      │
                      ▼
              ┌───────────────┐
              │   Backend     │
              │   Server      │
              │ - Socket.IO   │
              │ - REST API    │
              │ - Signaling   │
              └───────────────┘
```

## WebRTC Connection Flow

```
Host Device                Socket.IO Server           Participant Device
─────────────              ────────────────           ──────────────────

1. Create Course
   │
   ├─[POST /api/live_courses]──────►
   │
   ◄───[Course + Meeting Code]──────┤
   │
   ├─[Initialize Camera/Mic]
   │  - getUserMedia()
   │  - Local stream ready
   │
   ├─[join-meeting]─────────────────►
   │  {meetingCode, isHost: true}
   │
   │                                       2. Join Course
   │                                          │
   │                      ◄────[POST /api/live_courses/join]
   │                      │
   │                      ├──[Meeting Info + Course]───►
   │                      │
   │                      │                  ├─[Initialize Camera/Mic]
   │                      │                  │  - getUserMedia()
   │                      │                  │  - Local stream ready
   │                      │                  │
   │                      ◄──[join-meeting]─┤
   │                      │  {meetingCode, participantId}
   │
   ◄─[participant-joined]─┤
   {participantId, name}
   │
   │
3. WebRTC Offer Creation
   │
   ├─[createPeerConnection(participantId)]
   │  - Add local tracks
   │  - Setup ICE handlers
   │
   ├─[createOffer()]
   │  - Generate SDP offer
   │
   ├─[setLocalDescription(offer)]
   │
   ├─[webrtc-offer]─────────────────►
   │  {offer, to: participantId}
   │
   │                      │                  4. WebRTC Answer Creation
   │                      │                  │
   │                      ├──[webrtc-offer]─►
   │                      │  {offer, from: hostId}
   │                      │
   │                      │                  ├─[createPeerConnection(hostId)]
   │                      │                  │  - Add local tracks
   │                      │                  │  - Setup ICE handlers
   │                      │                  │
   │                      │                  ├─[setRemoteDescription(offer)]
   │                      │                  │
   │                      │                  ├─[createAnswer()]
   │                      │                  │  - Generate SDP answer
   │                      │                  │
   │                      │                  ├─[setLocalDescription(answer)]
   │                      │                  │
   │                      ◄─[webrtc-answer]─┤
   │                      │  {answer, to: hostId}
   │
   ◄─[webrtc-answer]──────┤
   │  {answer, from: participantId}
   │
   ├─[setRemoteDescription(answer)]
   │
   │
5. ICE Candidate Exchange
   │
   ├─[onicecandidate]
   │  - Generate ICE candidates
   │
   ├─[webrtc-ice-candidate]─────────►
   │  {candidate, to: participantId}
   │
   │                      ├──[webrtc-ice-candidate]─►
   │                      │  {candidate, from: hostId}
   │                      │
   │                      │                  ├─[addIceCandidate(candidate)]
   │                      │                  │
   │                      │                  ├─[onicecandidate]
   │                      │                  │  - Generate ICE candidates
   │                      │                  │
   │                      ◄─[webrtc-ice-candidate]─┤
   │                      │  {candidate, to: hostId}
   │
   ◄─[webrtc-ice-candidate]─────────┤
   │  {candidate, from: participantId}
   │
   ├─[addIceCandidate(candidate)]
   │
   │
6. Connection Established ✓
   │                                          │
   ├─────── Direct P2P Media Stream ─────────┤
   │         (Audio + Video Tracks)           │
   │◄─────────────────────────────────────────►
   │                                          │
   │  Both see each other's video/audio      │
```

## Media Stream Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    Local Device                             │
│                                                             │
│  ┌──────────┐         ┌──────────────┐                     │
│  │  Camera  │────────►│              │                     │
│  └──────────┘         │ getUserMedia │                     │
│                       │              │                     │
│  ┌──────────┐         │              │                     │
│  │   Mic    │────────►│              │                     │
│  └──────────┘         └──────┬───────┘                     │
│                              │                             │
│                              ▼                             │
│                    ┌──────────────────┐                    │
│                    │  MediaStream     │                    │
│                    │  - audioTrack    │                    │
│                    │  - videoTrack    │                    │
│                    └─────┬──────┬─────┘                    │
│                          │      │                          │
│                          │      └──────────────┐           │
│                          │                     │           │
│                          ▼                     ▼           │
│                 ┌─────────────────┐   ┌──────────────┐    │
│                 │ RTCVideoRenderer│   │ RTCPeerConn  │    │
│                 │ (Local Preview) │   │ (Send to     │    │
│                 │ - Mirror mode   │   │  Remote)     │    │
│                 └─────────────────┘   └──────┬───────┘    │
│                          │                   │            │
│                          ▼                   │            │
│                 ┌─────────────────┐          │            │
│                 │  Local Video    │          │            │
│                 │  Overlay (UI)   │          │            │
│                 │  150x200px      │          │            │
│                 └─────────────────┘          │            │
│                                              │            │
└──────────────────────────────────────────────┼────────────┘
                                               │
                                               │ P2P Connection
                                               │ (via STUN/TURN)
                                               │
┌──────────────────────────────────────────────┼────────────┐
│                    Remote Device             │            │
│                                              │            │
│                                              ▼            │
│                                   ┌──────────────┐        │
│                                   │ RTCPeerConn  │        │
│                                   │ (Receive)    │        │
│                                   └──────┬───────┘        │
│                                          │                │
│                                          ▼                │
│                                 ┌──────────────────┐      │
│                                 │  MediaStream     │      │
│                                 │  - audioTrack    │      │
│                                 │  - videoTrack    │      │
│                                 └─────┬──────┬─────┘      │
│                                       │      │            │
│                                       │      └──────────┐ │
│                                       ▼                 │ │
│                              ┌─────────────────┐        │ │
│                              │ RTCVideoRenderer│        │ │
│                              │ (Remote Video)  │        │ │
│                              └────────┬────────┘        │ │
│                                       │                 │ │
│                                       ▼                 ▼ │
│                              ┌─────────────────┐  ┌────────┐
│                              │  Remote Video   │  │Speaker │
│                              │  Grid (UI)      │  │Audio   │
│                              │  GridView       │  │Output  │
│                              └─────────────────┘  └────────┘
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## State Management

```
┌────────────────────────────────────────────────────────┐
│            Meeting Room Screen State                   │
│                                                        │
│  ┌──────────────────────────────────────────────┐     │
│  │  Video State                                 │     │
│  │  - _localRenderer: RTCVideoRenderer          │     │
│  │  - _remoteRenderers: Map<String, Renderer>   │     │
│  │  - _isInitializingMedia: bool                │     │
│  └──────────────────────────────────────────────┘     │
│                                                        │
│  ┌──────────────────────────────────────────────┐     │
│  │  Media Control State                         │     │
│  │  - _isMuted: bool                            │     │
│  │  - _isCameraOff: bool                        │     │
│  └──────────────────────────────────────────────┘     │
│                                                        │
│  ┌──────────────────────────────────────────────┐     │
│  │  Participant State                           │     │
│  │  - _participants: List<Participant>          │     │
│  │  - _chatMessages: List<ChatMessage>          │     │
│  └──────────────────────────────────────────────┘     │
│                                                        │
│  ┌──────────────────────────────────────────────┐     │
│  │  UI State                                    │     │
│  │  - _showChat: bool                           │     │
│  └──────────────────────────────────────────────┘     │
│                                                        │
└────────────────────────────────────────────────────────┘

State Updates Trigger:
  │
  ├─ Media initialization → _isInitializingMedia = true/false
  │
  ├─ Remote stream added → _remoteRenderers[id] = new renderer
  │                       → setState() → UI rebuilds
  │
  ├─ Participant joins   → _participants.add()
  │                       → createOffer(participantId)
  │
  ├─ Toggle audio/video  → _isMuted/_isCameraOff toggle
  │                       → webrtcService.toggle*()
  │                       → setState() → UI updates
  │
  └─ Participant leaves  → _remoteRenderers.remove(id)
                         → _participants.remove()
                         → setState() → UI rebuilds
```

## Component Interaction

```
┌──────────────────────────────────────────────────────────────┐
│                     User Actions                             │
└────────────┬─────────────────────────────────────────────────┘
             │
             ▼
┌──────────────────────────────────────────────────────────────┐
│              Meeting Room Screen Widget                      │
│                                                              │
│  Widget build() {                                           │
│    - AppBar (meeting code, chat toggle)                     │
│    - Main area (video grid)                                 │
│    - Controls (mute, camera, leave)                         │
│    - Sidebar (chat + participants)                          │
│  }                                                           │
└─────┬────────────────────────────────────────────────┬───────┘
      │                                                │
      ▼                                                ▼
┌─────────────────────┐                    ┌──────────────────┐
│  _buildControlButton│                    │ _buildRemoteVid- │
│  - Icon + Label     │                    │ eosGrid()        │
│  - onPressed callback│                   │ - GridView       │
└──────┬──────────────┘                    │ - RTCVideoView   │
       │                                   │ - Participant    │
       │                                   │   labels         │
       │                                   └──────────────────┘
       ▼
┌────────────────────────────────────────────────────┐
│           User Action Handlers                     │
│                                                    │
│  onPressed: () {                                  │
│    _webrtcService.toggleAudio();                  │
│    setState(() { _isMuted = !_isMuted; });        │
│  }                                                 │
│                                                    │
│  _webrtcService callback:                         │
│    onRemoteStreamAdded: (stream, id) {            │
│      setState(() {                                │
│        _remoteRenderers[id] = new renderer        │
│      });                                           │
│    }                                               │
└────────────────────────────────────────────────────┘
```

## Lifecycle Management

```
┌────────────────────────────────────────────────────┐
│             Widget Lifecycle                       │
│                                                    │
│  initState()                                      │
│    ├─ _initializeRenderers()                     │
│    │   └─ await _localRenderer.initialize()      │
│    │                                              │
│    ├─ _initializeSocket()                        │
│    │   ├─ _socketService.connect()               │
│    │   ├─ _socketService.joinMeetingRoom()       │
│    │   └─ Setup event listeners                  │
│    │       ├─ onParticipantJoined                │
│    │       ├─ onParticipantLeft                  │
│    │       ├─ onChatMessage                      │
│    │       └─ onMeetingEnded                     │
│    │                                              │
│    ├─ _initializeMedia()                         │
│    │   ├─ _webrtcService.initializeLocalMedia()  │
│    │   │   └─ getUserMedia()                     │
│    │   ├─ _localRenderer.srcObject = stream      │
│    │   ├─ _webrtcService.setupSignaling()        │
│    │   └─ Setup callbacks                        │
│    │       ├─ onRemoteStreamAdded                │
│    │       └─ onRemoteStreamRemoved              │
│    │                                              │
│    └─ _addParticipant(currentParticipant)        │
│                                                   │
│  build()                                          │
│    └─ Render UI with current state               │
│                                                   │
│  dispose()                                        │
│    ├─ _socketService.removeAllListeners()        │
│    ├─ _webrtcService.cleanup()                   │
│    │   ├─ Stop local stream tracks               │
│    │   ├─ Close all peer connections             │
│    │   └─ Dispose remote streams                 │
│    ├─ _localRenderer.dispose()                   │
│    └─ for (renderer in _remoteRenderers)         │
│        └─ renderer.dispose()                     │
│                                                   │
└────────────────────────────────────────────────────┘
```

This architecture ensures:
- Clean separation of concerns
- Proper resource management
- Reactive UI updates
- Scalable multi-participant support
- Easy debugging and maintenance
