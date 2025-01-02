import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';

class CreateEventScreen extends StatelessWidget {
  final EventService eventService = EventService();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _ticketPriceController = TextEditingController();
  final TextEditingController _maxTicketsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Event")),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Event Name"),
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              // More fields for other event data...
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final event = Event(
                      id: '',
                      name: _nameController.text,
                      description: _descriptionController.text,
                      location: _locationController.text,
                      date: DateTime.now(),
                      ticketPrice: double.parse(_ticketPriceController.text),
                      maxTickets: int.parse(_maxTicketsController.text),
                      soldTickets: 0,
                      status: 'OPEN',
                    );
                    eventService.createEvent(event);
                  }
                },
                child: Text("Create Event"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
