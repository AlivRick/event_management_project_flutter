import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/ticket_detail_model.dart';
import '../../models/user_model.dart';
import '../../models/event_model.dart';
import '../../widgets/navigation_helper.dart';
import 'event_list_screen.dart';
import 'user_info_screen.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({Key? key}) : super(key: key);

  @override
  _TicketScreenState createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String currentUserId;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final List<Widget> _screens = [
    EventListScreen(),
    TicketScreen(),
    UserInfoScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    NavigationHelper.navigateToScreen(context, index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Danh sách vé',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Vé chưa sử dụng'),
            Tab(text: 'Vé đã sử dụng'),
            Tab(text: 'Vé hết hạn'),
          ],
          indicatorColor: const Color(0xFF2ECC71), // Màu chỉ báo của tab
        ),
        backgroundColor: const Color(0xFF2ECC71), // Màu xanh lá
      ),
      body: Container(
        color: const Color(0xFF1B1B1B), // Nền màu đen xám
        child: TabBarView(
          controller: _tabController,
          children: [
            TicketList(isUsed: false, userId: currentUserId, isExpired: false),
            TicketList(isUsed: true, userId: currentUserId, isExpired: false),
            TicketList(isUsed: false, userId: currentUserId, isExpired: true),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF2ECC71), // Màu xanh lá khi chọn
        unselectedItemColor: Colors.white, // Màu trắng khi chưa chọn
        backgroundColor: Colors.grey, // Màu nền xám
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Sự kiện',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer),
            label: 'Vé',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}

class TicketList extends StatelessWidget {
  final bool isUsed;
  final String userId;
  final bool isExpired;

  const TicketList({Key? key, required this.isUsed, required this.userId, required this.isExpired}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchTickets(isUsed, isExpired),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}', style: TextStyle(color: Colors.white)));
        }

        final tickets = snapshot.data ?? [];

        if (tickets.isEmpty) {
          return Center(
            child: Text(
              isUsed
                  ? 'Không có vé đã sử dụng'
                  : isExpired == true ? 'Không có vé hết hạn' : 'Không có vé chưa sử dụng',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return ListView.builder(
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            final ticketData = tickets[index];
            final ticket = ticketData['ticket'] as TicketDetail;
            final eventName = ticketData['eventName'];
            final ticketTypeName = ticketData['ticketTypeName'];

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              color: Colors.grey[800],
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: QrImageView(
                        data: ticket.id,
                        size: 100.0,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Tên sự kiện: $eventName',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Roboto'),
                    ),
                    Text(
                      'Loại vé: $ticketTypeName',
                      style: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
                    ),
                    Text(
                      '${ticket.price.toStringAsFixed(0)} VND',
                      style: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchTickets(bool isUsed, bool isExpired) async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final querySnapshot = await FirebaseFirestore.instance
          .collection('invoices')
          .where('user_id', isEqualTo: userId)
          .get();

      List<Map<String, dynamic>> allTickets = [];

      for (var doc in querySnapshot.docs) {
        var invoiceData = doc.data() as Map<String, dynamic>;

        if (invoiceData['ticket_details'] is List) {
          var ticketDetailsFromInvoice = (invoiceData['ticket_details'] as List)
              .map((ticketDetail) => TicketDetail.fromMap(ticketDetail))
              .toList();

          for (var ticket in ticketDetailsFromInvoice) {
            // Lấy thông tin loại vé và sự kiện
            String ticketTypeName = await fetchTicketTypeName(ticket.ticketTypeId);
            String eventName = await fetchEventNameFromTicketType(ticket.ticketTypeId);

            // Kiểm tra vé hết hạn hoặc đã sử dụng
            bool isTicketExpired = await checkIfTicketIsExpired(ticket.ticketTypeId);
            print(isTicketExpired);
            // Logic phân loại vé
            if (isUsed == true) {
              // Vé đã sử dụng (bao gồm cả hết hạn)
              if (ticket.isUsed == true) {
                allTickets.add({
                  'ticket': ticket,
                  'eventName': eventName,
                  'ticketTypeName': ticketTypeName,
                });
              }
            } else if (isUsed == false && isExpired == false) {
              // Vé chưa sử dụng
              if (ticket.isUsed == false && isTicketExpired == false) {
                allTickets.add({
                  'ticket': ticket,
                  'eventName': eventName,
                  'ticketTypeName': ticketTypeName,
                });
              }
            } else if (isUsed == false && isExpired == true) {
              // Vé chưa sử dụng nhưng đã hết hạn
              if (ticket.isUsed == false && isTicketExpired == true) {
                allTickets.add({
                  'ticket': ticket,
                  'eventName': eventName,
                  'ticketTypeName': ticketTypeName,
                });
              }
            }
          }
        }
      }


      return allTickets;
    } catch (e) {
      debugPrint('Lỗi khi lấy danh sách vé: $e');
      throw Exception('Không thể lấy danh sách vé.');
    }
  }
  Future<String> fetchTicketTypeName(String ticketTypeId) async {
    try {
      final ticketTypeSnapshot = await FirebaseFirestore.instance
          .collection('ticket_types')
          .doc(ticketTypeId)
          .get();

      if (ticketTypeSnapshot.exists) {
        var ticketTypeData = ticketTypeSnapshot.data() as Map<String, dynamic>;
        return ticketTypeData['name'] ?? 'Không xác định';
      }
      return 'Không xác định';
    } catch (e) {
      debugPrint('Lỗi khi lấy tên loại vé: $e');
      return 'Không xác định';
    }
  }

  Future<String> fetchEventNameFromTicketType(String ticketTypeId) async {
    try {
      final ticketTypeSnapshot = await FirebaseFirestore.instance
          .collection('ticket_types')
          .doc(ticketTypeId)
          .get();

      if (ticketTypeSnapshot.exists) {
        var ticketTypeData = ticketTypeSnapshot.data() as Map<String, dynamic>;
        String eventId = ticketTypeData['event_id'];

        final eventSnapshot = await FirebaseFirestore.instance
            .collection('events')
            .doc(eventId)
            .get();

        if (eventSnapshot.exists) {
          var eventData = eventSnapshot.data() as Map<String, dynamic>;
          return eventData['name'] ?? 'Không xác định';
        }
      }
      return 'Không xác định';
    } catch (e) {
      debugPrint('Lỗi khi lấy tên sự kiện: $e');
      return 'Không xác định';
    }
  }


  Future<bool> checkIfTicketIsExpired(String ticketTypeId) async {
    try {
      final ticketTypeSnapshot = await FirebaseFirestore.instance
          .collection('ticket_types')
          .where('id', isEqualTo: ticketTypeId)
          .limit(1)
          .get();

      if (ticketTypeSnapshot.docs.isNotEmpty) {
        var ticketTypeData = ticketTypeSnapshot.docs.first.data() as Map<String, dynamic>;
        String eventId = ticketTypeData['event_id'];
        final eventSnapshot = await FirebaseFirestore.instance
            .collection('events')
            .where('id', isEqualTo: eventId)
            .limit(1)
            .get();

        if (eventSnapshot.docs.isNotEmpty) {
          var eventData = eventSnapshot.docs.first.data() as Map<String, dynamic>;
          final event = Event.fromMap(eventData);
          Timestamp eventTimestamp = eventData['date'] as Timestamp;
          DateTime eventDate = eventTimestamp.toDate(); // Chuyển đổi từ Timestamp sang DateTime
          debugPrint('Ngày của sự kiện: $eventDate'); // In ra giá trị eventDate
          return event.date.isBefore(DateTime.now());
        }
      }
      return false;
    } catch (e) {
      debugPrint('Lỗi khi lấy sự kiện: $e');
      return false;
    }
  }
}
