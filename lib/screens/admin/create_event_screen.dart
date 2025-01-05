import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/event_model.dart';
import '../../models/ticket_type_model.dart';
import '../../services/event_service.dart';
import '../../services/ticket_service.dart';
import '../../widgets/ticket_type_widget.dart';

class CreateEventScreen extends StatefulWidget {
  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final EventService eventService = EventService();
  final TicketService ticketService = TicketService();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  List<TicketType> _ticketTypes = [];
  bool _isLoading = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final String imgurClientID = 'aa1a3b5dbb6b0c5'; // Thay thế bằng Client ID của bạn

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Event")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // Event Name Field
              TextFormField(
                controller: _nameController,
                decoration:
                const InputDecoration(labelText: "Event Name"),
                validator: (value) => value == null || value.isEmpty
                    ? "Event name is required"
                    : null,
              ),
              const SizedBox(height: 10),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration:
                const InputDecoration(labelText: "Description"),
                validator: (value) => value == null || value.isEmpty
                    ? "Description is required"
                    : null,
              ),
              const SizedBox(height: 10),

              // Location Field
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: "Location"),
                validator: (value) => value == null || value.isEmpty
                    ? "Location is required"
                    : null,
              ),
              const SizedBox(height: 20),

              // Image Selector
              Column(
                children: [
                  _selectedImage == null
                      ? const Text("No image selected.")
                      : kIsWeb
                      ? Image.network(
                    _selectedImage!.path,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                      : Image.file(
                    File(_selectedImage!.path),
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text("Choose Image"),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // List of Ticket Types
              ..._ticketTypes.map((ticketType) {
                return TicketTypeWidget(
                  title: ticketType.name,
                  price: ticketType.price.toString(),
                  maxTickets: ticketType.maxTickets.toString(),
                  onDelete: () {
                    setState(() {
                      _ticketTypes.remove(ticketType);
                    });
                  },
                  onUpdate: (title, price, maxTickets) {
                    setState(() {
                      final updatedTicket = TicketType(
                        id: ticketType.id,
                        eventId: ticketType.eventId,
                        name: title,
                        price: double.tryParse(price) ?? 0.0,
                        maxTickets: int.tryParse(maxTickets) ?? 0,
                        soldTickets: ticketType.soldTickets,
                      );

                      final index = _ticketTypes
                          .indexWhere((t) => t.id == ticketType.id);
                      if (index != -1) {
                        _ticketTypes[index] = updatedTicket;
                      }
                    });
                  },
                );
              }).toList(),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _ticketTypes.add(TicketType(
                      id: UniqueKey().toString(),
                      eventId: '',
                      name: 'New Ticket',
                      price: 0.0,
                      maxTickets: 100,
                      soldTickets: 0,
                    ));
                  });
                },
                child: const Text("Add Ticket Type"),
              ),
              const SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: _createEvent,
                child: const Text("Create Event"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

  Future<String?> _uploadToImgur(XFile image) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.imgur.com/3/upload'),
    );
    request.headers['Authorization'] = 'Client-ID $imgurClientID';
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    final response = await request.send();
    final responseData = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      final result = json.decode(responseData.body);
      return result['data']['link']; // URL của ảnh đã tải lên
    } else {
      throw Exception('Failed to upload image to Imgur');
    }
  }

  Future<void> _createEvent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String? imageUrl;

        // Nếu có ảnh được chọn, upload lên Imgur
        if (_selectedImage != null) {
          imageUrl = await _uploadToImgur(_selectedImage!);
        }

        // Tạo sự kiện
        final event = Event(
          id: '',
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          location: _locationController.text.trim(),
          date: DateTime.now(),
          status: 'OPEN',
          imageUrl: imageUrl,
        );

        // Lưu sự kiện vào Firestore
        final eventId = await eventService.createEvent(event);

        // Cập nhật thông tin ticket
        List<TicketType> updatedTicketTypes = [];
        for (var ticketType in _ticketTypes) {
          final ticketTypeMap = ticketType.toMap();
          ticketTypeMap['event_id'] = eventId;

          final createdTicket = await ticketService.createTicketType(TicketType.fromMap(ticketTypeMap));
          updatedTicketTypes.add(createdTicket);
        }

        setState(() {
          _ticketTypes = updatedTicketTypes;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Event and Ticket Types created successfully")),
        );

        _resetForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _resetForm() {
    _nameController.clear();
    _descriptionController.clear();
    _locationController.clear();
    setState(() {
      _ticketTypes = [];
      _selectedImage = null;
    });
  }
}
