import 'package:flutter/material.dart';
import '../../services/event_service.dart';
import '../../models/event_model.dart';

class ManageEventScreen extends StatelessWidget {
  final EventService _eventService = EventService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manage Events")),
      body: StreamBuilder<List<Event>>(
        stream: _eventService.getEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No events found"));
          } else {
            final events = snapshot.data!;
            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return ListTile(
                  title: Text(event.name),
                  subtitle: Text(event.status),
                  trailing: ElevatedButton(
                    onPressed: () {
                      final newStatus = event.status == 'OPEN' ? 'CLOSED' : 'OPEN';
                      _eventService.updateEventStatus(event.id, newStatus);
                    },
                    child: Text(event.status == 'OPEN' ? 'Close' : 'Open'),
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
