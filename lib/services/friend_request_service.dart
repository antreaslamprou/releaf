import 'package:firebase_database/firebase_database.dart';
import 'package:releaf/services/user_service.dart';

class FriendRequestService {
  final _userService = UserService();
  final _database = FirebaseDatabase.instance;

  Future<String> sendFriendRequest(String receiverUsername) async {
    final senderId = _userService.getUserUID();

    final receiverId = await _userService.getUserUIDFromUsername(
      receiverUsername,
    );

    final senderUsername = await _userService.getUsernameFromUID(senderId);

    final requestId = '${senderId}_$receiverId';
    final revertedRequestId = '${receiverId}_$senderId';

    if (senderId == receiverId) return 'same-user';

    final isExistingFriend = await _database
        .ref('users/$senderId/friends/$receiverId')
        .get();

    if (isExistingFriend.exists) return 'existing-friend';

    final isAlreadyRequested = await _database
        .ref('friend_requests/$requestId')
        .get();

    if (isAlreadyRequested.exists) return 'existing-request';

    final isPendingRequest = await _database
        .ref('friend_requests/$revertedRequestId')
        .get();

    if (isPendingRequest.exists) return 'pending-incoming-request';

    await _database.ref('friend_requests/$requestId').set({
      'sender_id': senderId,
      'sender_username': senderUsername,
      'receiver_id': receiverId,
      'receiver_username': receiverUsername,
      'created_at': ServerValue.timestamp,
    });

    return 'ok';
  }

  Future<List<dynamic>> getIncomingFriendRequest() async {
    final snpashot = await _database
        .ref('friend_requests')
        .orderByChild('receiver_id')
        .equalTo(_userService.getUserUID())
        .get();

    if (!snpashot.exists) return [];

    final dataMap = snpashot.value as Map<dynamic, dynamic>;

    final senderIds = dataMap.values
        .map((request) => request['sender_id'] as String)
        .toList();

    return senderIds;
  }

  Future<List<dynamic>> getOutgoingFriendRequest() async {
    final snpashot = await _database
        .ref('friend_requests')
        .orderByChild('sender_id')
        .equalTo(_userService.getUserUID())
        .get();

    if (!snpashot.exists) return [];

    final dataMap = snpashot.value as Map<dynamic, dynamic>;

    final receiverIds = dataMap.values
        .map((request) => request['receiver_id'] as String)
        .toList();

    return receiverIds;
  }

  Future<void> cancelOutgoingRequest({
    String receiverId = 'user',
    String senderId = 'user',
  }) async {
    if (senderId == 'user') senderId = _userService.getUserUID();
    if (receiverId == 'user') receiverId = _userService.getUserUID();
    await _database.ref('friend_requests/${senderId}_$receiverId').remove();
  }
}
