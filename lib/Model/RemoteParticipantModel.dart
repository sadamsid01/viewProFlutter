class RemoteParticipant {
  final int uid;
  bool isVideoMuted;
  bool isAudioMuted;

  RemoteParticipant({
    required this.uid,
    this.isVideoMuted = true,
    this.isAudioMuted = true,
  });
}