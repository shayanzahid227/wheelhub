import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wheelhub/core/constant/colors.dart';
import 'package:wheelhub/providers/vehicle_provider.dart';
import 'package:wheelhub/screens/chat/chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final threads = context.watch<VehicleProvider>().chatThreads;

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: threads.isEmpty
          ? const Center(
              child: Text(
                'No conversations yet.\nStart chatting from a vehicle detail page.',
                textAlign: TextAlign.center,
                style: TextStyle(color: greyColor),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: threads.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final thread = threads[index];
                final last = thread.messages.last;
                return ListTile(
                  tileColor: planCardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: borderColor),
                  ),
                  leading: const CircleAvatar(
                    child: Icon(Icons.storefront_outlined),
                  ),
                  title: Text(thread.vehicleTitle),
                  subtitle: Text(
                    last.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    thread.sellerName,
                    style: const TextStyle(color: greyColor, fontSize: 11),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(vehicleId: thread.vehicleId),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
