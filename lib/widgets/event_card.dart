import 'package:flutter/material.dart';
import '../models/event_model.dart';

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(event.name),
        subtitle: Text(event.description),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("Tickets: ${event.soldTickets}/${event.maxTickets}"),
            Text("Status: ${event.status}"),
          ],
        ),
        onTap: () {
          Navigator.pushNamed(context, '/event_detail', arguments: event);
        },
      ),
    );
  }
}
