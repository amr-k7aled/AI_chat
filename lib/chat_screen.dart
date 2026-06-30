import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final List<Map<String, dynamic>> messages = [];

  bool isLoading = false;

  static const String apiKey = "AQ.Ab8RN6IU5uqALsKtjJZx0QUy6s14qWR-JSCLjrmVbPxFvD5mSg";

  final Dio dio = Dio();

  Future<void> sendMessage() async {
    if (controller.text.trim().isEmpty) return;

    final text = controller.text.trim();

    setState(() {
      messages.add({
        "role": "user",
        "text": text,
      });
      isLoading = true;
    });

    controller.clear();

    try {
      final response = await dio.post(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey",
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
        data: {
          "contents": [
            {
              "parts": [
                {
                  "text": text,
                }
              ]
            }
          ]
        },
      );

      String reply = response.data["candidates"][0]["content"]["parts"][0]["text"];

      setState(() {
        messages.add({
          "role": "assistant",
          "text": reply,
        });
      });
    } on DioException catch (e) {
      setState(() {
        messages.add({
          "role": "assistant",
          "text": e.response?.data.toString() ?? e.message ?? "حدث خطأ",
        });
      });
    } catch (e) {
      setState(() {
        messages.add({
          "role": "assistant",
          "text": e.toString(),
        });
      });
    }

    setState(() {
      isLoading = false;
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget suggestion(String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(fontSize: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F0FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Color(0xffF5EDFF),
                  Color(0xffF8E1EE),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [

                  Expanded(
                    child: messages.isEmpty
                        ? Column(
                      children: [

                        const Spacer(),

                        const Icon(
                          Icons.auto_awesome,
                          size: 34,
                        ),

                        const SizedBox(height: 20),

                        Text(
                          "Ask our AI anything",
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const Spacer(),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Suggestions on what to ask Our AI",
                            style: GoogleFonts.poppins(
                              color: Colors.grey,
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        Row(
                          children: [
                            suggestion(
                                "What can I ask you to do?"),
                            const SizedBox(width: 10),
                            suggestion(
                                "What projects should I be concerned about right now?"),
                          ],
                        ),

                        const SizedBox(height: 20),
                      ],
                    )
                        : ListView.builder(
                      controller: scrollController,
                      itemCount:
                      messages.length + (isLoading ? 1 : 0),
                      itemBuilder: (context, index) {

                        if (isLoading &&
                            index == messages.length) {
                          return const Padding(
                            padding: EdgeInsets.all(12),
                            child: Row(
                              children: [
                                CircularProgressIndicator(),
                              ],
                            ),
                          );
                        }

                        final msg = messages[index];

                        bool isUser =
                            msg["role"] == "user";

                        return Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin:
                            const EdgeInsets.symmetric(
                              vertical: 6,
                            ),
                            padding:
                            const EdgeInsets.all(14),
                            constraints:
                            const BoxConstraints(
                              maxWidth: 300,
                            ),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? Colors.deepPurple
                                  : Colors.white,
                              borderRadius:
                              BorderRadius.circular(18),
                            ),
                            child: Text(
                              msg["text"],
                              style:
                              GoogleFonts.poppins(
                                color: isUser
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  Container(
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      children: [

                        const SizedBox(width: 14),

                        Expanded(
                          child: TextField(
                            controller: controller,
                            decoration:
                            const InputDecoration(
                              hintText:
                              "Ask me anything about your projects",
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) =>
                                sendMessage(),
                          ),
                        ),

                        IconButton(
                          onPressed: sendMessage,
                          icon: const Icon(
                            Icons.send_rounded,
                            color: Color(0xff91A4D6),
                            size: 28,
                          ),
                        ),

                        const SizedBox(width: 6),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}