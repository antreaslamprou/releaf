import 'package:firebase_database/firebase_database.dart';
import 'package:releaf/utils/user_image.dart';
import 'package:releaf/services/task_service.dart';
import 'package:releaf/utils/conversions.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // Get important firebase services for public data
  final _database = FirebaseDatabase.instance;

  // Get the AI API key
  Future<String> getAiApiKey() async {
    final snapshot = await _database.ref('env/OPENROUTER_API_KEY').get();
    final apiKey = snapshot.value as String;
    return apiKey;
  }

  Future<String> analyzeImage(UserImage imageFile) async {
    // Image as base and jpeg (api accepted format)
    final base64Image = await Conversions.userImageToBase(
      imageFile,
      isWebp: false,
    );

    // Get API key from database
    final apiKey = await ApiService().getAiApiKey();

    // Get current task
    final taskData = await TaskService().getDailyTask();

    // The prompt to check the image
    final prompt =
        '''
        You are an AI that verifies proof of task completion and performs safety checks.

        Task: ${taskData['title']}

        Task Example (for guidance only):
        ${taskData['description']}

        Important:
        - The example is illustrative only.
        - The user may provide different valid proof that still demonstrates task completion.
        - Do NOT require the image to match the example exactly.

        Instructions:
        - Examine the provided image carefully.
        - First, check whether the image contains any nudity or violence.
            - Nudity includes exposed genitals, breasts, or explicit sexual acts.
            - Violence includes physical harm, weapons, blood, or threats of harm.
            - Drugs includes visible drugs or clear use of drugs.
        - If nudity or violence is detected, the image is automatically invalid.
        - If no nudity or violence is present, determine whether the image is valid proof that the task has been completed.
        - The provided image may be accepted as valid proof of task completion only if the task can be clearly and logically inferred from the image (e.g., a person in motion → Exercise/Move Your Body), and the image must be a real, camera-captured photo, not an icon or AI-generated image.
        
        Answer rules:
        - Respond in ONE sentence only.
        - Start the response with "True -" if the image is valid proof.
        - Start the response with "False -" if the image is invalid.
        - If the response is "True", do NOT include any explanation.
        - If the response is "False", include ONE clear reason from the following list:
          - "Contains nudity, which is restricted!"
          - "Contains violence, which is restricted!"
          - "Contains drugs, which is restricted!"
          - "Does not show valid proof of task completion!"

        Answer format:
        True -
        False - <reason>
      ''';

    final response = await http.post(
      Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        'HTTP-Referer':
            'https://releaf.app', // Dummy domain to show on OpenRouter
        'X-Title': 'ReLeaf',
      },
      body: jsonEncode({
        "model": "nvidia/nemotron-nano-12b-v2-vl:free",
        "messages": [
          {
            "role": "user",
            "content": [
              {"type": "text", "text": prompt},
              {
                "type": "image_url",
                "image_url": "data:image/jpeg;base64,$base64Image",
              },
            ],
          },
        ],
      }),
    );

    // If the api cant return an answer, return the error
    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      final message = errorData['error']?['message'] ?? 'Unknown error';

      return 'False - OpenRouter error: $message';
    }

    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'];
  }
}
