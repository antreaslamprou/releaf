import 'package:firebase_database/firebase_database.dart';
import 'package:releaf/services/task_service.dart';
import 'package:releaf/utils/conversions.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ApiService {
  // Get important firebase services for public data
  final _database = FirebaseDatabase.instance;

  // Get the AI API key
  Future<String> getAiApiKey() async {
    final snapshot = await _database.ref('env/OPENROUTER_API_KEY').get();
    final apiKey = snapshot.value as String;
    return apiKey;
  }

  Future<String> analyzeImage(File imageFile) async {
    // Image as base and jpeg (api accepted format)
    final base64Image = await Conversions.imageToBase(imageFile, isWebp: false);

    // Get API key from database
    final apiKey = await ApiService().getAiApiKey();

    // Get current task
    final taskData = await TaskService().getDailyTask();
    final taskTitle = taskData['title'];

    // The prompt to check the image
    final prompt =
        '''
      You are an AI that verifies proof of task completion. 

      Task: $taskTitle

      Instructions:
      - Examine the provided image.
      - Determine whether it is valid proof that the task is completed.
      - Answer in one sentence only:
          1. Start with "True" if the image is valid proof, or "False" if it is not.
          2. If "False", provide a short explanation of why the image is invalid.
          3. If "True", no explanation is necessary.

      Answer format:
      True - (no explanation if valid)
      False - <short reason why image is not valid>
      ''';

    final response = await http.post(
      Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        'HTTP-Referer':
            'https://releaf.app', // Dummy domain to show on OpenRouter
        'X-Title': 'ReLeaf',
        'X-Description': 'Task verification using AI',
      },
      body: jsonEncode({
        "model": "allenai/molmo-2-8b:free",
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
      final provider =
          errorData['error']?['metadata']?['provider_name'] ?? 'Unknown';
      final message = errorData['error']?['message'] ?? 'Unknown error';

      return 'False - OpenRouter error from $provider: $message';
    }

    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'];
  }
}
