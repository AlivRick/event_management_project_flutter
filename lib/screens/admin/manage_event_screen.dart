import 'package:flutter/material.dart';
import '../../services/event_service.dart';
import '../../models/event_model.dart';

class ManageEventScreen extends StatelessWidget {
  final EventService _eventService = EventService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1B1B1B), // Nền xám đậm
      appBar: AppBar(
        title: Text(
          "Manage Events",
          style: TextStyle(
            fontFamily: 'Roboto', // Font chữ đồng bộ
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF2ECC71), // Màu xanh lá cây
      ),
      body: StreamBuilder<List<Event>>(
        stream: _eventService.getEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: Colors.white)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No events found", style: TextStyle(color: Colors.white)));
          } else {
            final events = snapshot.data!;
            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Card(
                  color: Color(0xFF333333), // Nền các card xám đậm
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    title: Text(
                      event.name,
                      style: const TextStyle(color: Colors.white, fontFamily: 'Roboto', fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      event.status,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        final newStatus = event.status == 'OPEN' ? 'CLOSED' : 'OPEN';
                        _eventService.updateEventStatus(event.id, newStatus);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2ECC71), // Màu xanh lá cây
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      ),
                      child: Text(
                        event.status == 'OPEN' ? 'Close' : 'Open',
                        style: const TextStyle(fontFamily: 'Roboto'),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
