import 'package:firebase_database/firebase_database.dart';
import 'package:releaf/services/user_service.dart';

class FriendRequestService {
  // Get important user defined services for altering user data
  final _userService = UserService();

  // Get important firebase services for public data
  final _database = FirebaseDatabase.instance;

  // Send a friend request to another user using the username
  Future<String> sendFriendRequest(String receiverUsername) async {
    final senderId = _userService.getUserUID();
    final senderUsername = await _userService.getUsernameFromUID(senderId);

    final receiverId = await _userService.getUserUIDFromUsername(
      receiverUsername,
    );

    if (senderId == receiverId) return 'same-user';

    final isExistingFriend = await _database
        .ref('users/$senderId/friends/$receiverId')
        .get();
    if (isExistingFriend.exists) return 'existing-friend';

    final requestId = '${senderId}_$receiverId';

    final isAlreadyRequested = await _database
        .ref('friend_requests/$requestId')
        .get();
    if (isAlreadyRequested.exists) return 'existing-request';

    final revertedRequestId = '${receiverId}_$senderId';

    final isPendingRequest = await _database
        .ref('friend_requests/$revertedRequestId')
        .get();
    if (isPendingRequest.exists) return 'pending-incoming-request';

    await _database.ref('friend_requests/$requestId').set({
      'sender_id': senderId,
      'sender_username': senderUsername,
      'receiver_id': receiverId,
      'receiver_username': receiverUsername,
    });

    return 'ok';
  }

  // Fetches all users that sent friend request to the current user
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

  // Fetches all users that the current user sent friend request to
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

  // Delete a request depending on the parameters provided, if the receiver id is
  // provided, the request is an outging request, if the sender is provided, the
  // request is an incoming request. Can be called when a request is accpeted so
  // it clears the request entry
  Future<void> deleteRequest({
    String receiverId = 'user',
    String senderId = 'user',
  }) async {
    if (senderId == 'user') senderId = _userService.getUserUID();
    if (receiverId == 'user') receiverId = _userService.getUserUID();
    await _database.ref('friend_requests/${senderId}_$receiverId').remove();
  }
}
